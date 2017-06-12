
variable "cluster_vpc" {
  description = "The vpc where the cluster will reside"
  default = "vpc-12345678" 
}

# The first subnet to put machines in, must be different avalability zone than subnet_id2 below
variable "subnet1" {
  default = "subnet-12345678"
}

# The second subnet to put machines in, must be different avalability zone than subnet_id1 abolve
variable "subnet2" {
  # If you don' want to give subnet as argument every time, uncomment line below and put your desired subnet id as default
  default = "subnet-12345678"
}

variable "region" {
  default = "eu-west-1"
}

variable "ecs_cluster_name" {
  description = "The name of the Amazon ECS cluster."

  # Change clustername to you preference
  default = "ecs-demo"
}

variable "amis" {
  description = "Which AMI to spawn. Defaults to the AWS ECS optimized images."

  # Change to the most current ami for your region found at http://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI_launch_latest.html  
  default = {
    eu-west-1 = "ami-a1e6f5c7"
  }
}

variable "autoscale_min" {
  default     = "1"
  description = "Minimum autoscale (number of EC2)"
}

variable "autoscale_max" {
  default     = "4"
  description = "Maximum autoscale (number of EC2)"
}

variable "autoscale_desired" {
  default     = "2"
  description = "Desired autoscale (number of EC2)"
}

variable "instance_type" {
  default = "t2.micro"
}

# To specify a specific tag of the Docker image use [-var image_tag="MYVERSIONTAG"] and replace MYVERSIONTAG with the desired tag
variable "image_tag" {
  description = "The docker image tag to use"
  default = "green"
}

variable "profile" {
  description = "The AWS account profile"
  default = "cloud_engineer"
}