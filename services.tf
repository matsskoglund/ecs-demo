resource "aws_alb_target_group" "ecs-tg" {
  name     = "${var.ecs_cluster_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.cluster_vpc}"


  health_check {
    # TODO: Change the path to your specific api.
    path     = "/"
    timeout  = "60"
    interval = "120"
    matcher  = "200,204"
  }
}

resource "aws_alb" "ecs-alb" {
  name            = "${var.ecs_cluster_name}-alb"
  security_groups = ["${aws_security_group.ecs_load_balancers.id}"]

  subnets = ["${var.subnet1}", "${var.subnet2}"]
}

resource "aws_alb_listener" "ecs-al" {
  load_balancer_arn = "${aws_alb.ecs-alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.ecs-tg.arn}"
    type             = "forward"
  }
}

resource "aws_alb_listener_rule" "ecs-lr" {
  listener_arn = "${aws_alb_listener.ecs-al.arn}"
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.ecs-tg.arn}"
  }

  condition {
    field  = "path-pattern"
    values = ["*"]
  }
}

resource "aws_ecs_task_definition" "ecs-td" {
  family                = "${var.ecs_cluster_name}"
  container_definitions = "${data.template_file.ecs-task-template.rendered}"

}

resource "aws_ecs_service" "ecs-service" {
  name            = "${var.ecs_cluster_name}-service"
  cluster         = "${aws_ecs_cluster.main.id}"
  task_definition = "${aws_ecs_task_definition.ecs-td.arn}"
  iam_role        = "${aws_iam_role.ecs_service_role.arn}"
  desired_count   = 2

  depends_on = ["aws_iam_role_policy.ecs_service_role_policy",
    "aws_alb_listener.ecs-al",
  ]

  load_balancer {
    target_group_arn = "${aws_alb_target_group.ecs-tg.arn}"
    container_name   = "${var.ecs_cluster_name}"
    container_port   = 80
  }
}
