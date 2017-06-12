provider "aws" {
  region = "${var.region}"
  profile= "${var.profile}"
}

resource "aws_security_group" "ecs_load_balancers" {
  name        = "${var.ecs_cluster_name}-load_balancers"
  description = "Allows all traffic"

  vpc_id = "${var.cluster_vpc}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # TODO: this probably only needs egress to the ECS security group.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs-sg" {
  name        = "${var.ecs_cluster_name}-sg"
  description = "Allows all traffic"

  vpc_id = "${var.cluster_vpc}"

  # Remove this and replace with a bastion host for SSHing into
  # individual machines.
  #ingress {
  #  from_port   = 0
  #  to_port     = 0
  #  protocol    = "-1"
  #  cidr_blocks = ["0.0.0.0/0"]
  #}

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = ["${aws_security_group.ecs_load_balancers.id}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_cluster" "main" {
  name = "${var.ecs_cluster_name}"
}

resource "aws_autoscaling_group" "ecs-ag" {
  name                 = "${var.ecs_cluster_name}-asg"
  min_size             = "${var.autoscale_min}"
  max_size             = "${var.autoscale_max}"
  desired_capacity     = "${var.autoscale_desired}"
  health_check_type    = "EC2"
  launch_configuration = "${aws_launch_configuration.ecs-lc.name}"

  vpc_zone_identifier = ["${var.subnet1}", "${var.subnet2}"]
}

resource "aws_launch_configuration" "ecs-lc" {
  image_id             = "${lookup(var.amis, var.region)}"
  instance_type        = "${var.instance_type}"
  security_groups      = ["${aws_security_group.ecs-sg.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.ecs-ip.name}"

  # If you want to use a key then uncomment line below
  #key_name                    = "${var.key_name}"

  associate_public_ip_address = true
  user_data                   = "#!/bin/bash\necho ECS_CLUSTER='${var.ecs_cluster_name}' > /etc/ecs/ecs.config"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "ecs_host_role" {
  name               = "${var.ecs_cluster_name}-ecs_host_role"
  assume_role_policy = "${file("policies/ecs-role.json")}"
}

resource "aws_iam_role_policy" "ecs_ecs_instance_role_policy" {
  name   = "${var.ecs_cluster_name}-ecs_instance_role_policy"
  policy = "${file("policies/ecs-instance-role-policy.json")}"
  role   = "${aws_iam_role.ecs_host_role.id}"
}

resource "aws_iam_role" "ecs_service_role" {
  name               = "${var.ecs_cluster_name}-ecs_service_role"
  assume_role_policy = "${file("policies/ecs-role.json")}"
}

resource "aws_iam_role_policy" "ecs_service_role_policy" {
  name   = "${var.ecs_cluster_name}-ecs_service_role_policy"
  policy = "${file("policies/ecs-service-role-policy.json")}"
  role   = "${aws_iam_role.ecs_service_role.id}"
}

resource "aws_iam_instance_profile" "ecs-ip" {
  name  = "${var.ecs_cluster_name}-instance_profile"
  path  = "/"
  roles = ["${aws_iam_role.ecs_host_role.name}"]
}

resource "aws_iam_role_policy" "ecr_container_policy" {
  name   = "${var.ecs_cluster_name}-ecr_container_policy"
  policy = "${file("policies/ecr-role-policy.json")}"
  role   = "${aws_iam_role.ecs_host_role.id}"
}

resource "aws_iam_role_policy" "log_policy" {
  name   = "${var.ecs_cluster_name}-log_policy"
  policy = "${file("policies/log-policy.json")}"
  role   = "${aws_iam_role.ecs_host_role.id}"
}

resource "aws_cloudwatch_log_group" "ecs-lg" {
  name              = "${var.ecs_cluster_name}-lg"
  retention_in_days = "7"

  tags {
    Environment = "experimentation"
    Application = "${var.ecs_cluster_name}"
  }
}

data "template_file" "ecs-task-template" {
  template = "${file("task-definitions/dmg-task-template.json.tpl")}"

  vars {
    image_tag  = "${var.image_tag}"
    log-group  = "${aws_cloudwatch_log_group.ecs-lg.name}"
    log-stream = "${var.ecs_cluster_name}-log"
    image-name = "${var.ecs_cluster_name}"
  }
}

output "alb-dns-name" {
  value = "${aws_alb.ecs-alb.dns_name}"
}
