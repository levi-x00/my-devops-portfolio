terraform {
  backend "s3" {}
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.11.0"
    }
  }
  required_version = ">=1.5.0"
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile

  default_tags {
    tags = {
      Environment = var.environment
      Application = var.application
      Purpose     = "DevOps Projects"
    }
  }
}

#####################################################################
# main service section
#####################################################################
module "service" {
  source = "../../modules/ecs-task/fargate"

  service_name     = var.service_name
  docker_file_path = "${path.module}/src"

  cpu    = var.cpu
  memory = var.memory
  port   = var.port

  path_pattern = "/*"

  listener_arn = local.listener_arn

  lb_sg_id     = local.cluster_info.alb_security_group_id
  cluster_info = local.cluster_info
  network_info = local.network_info

  min_capacity = 1
  max_capacity = 1

  target_value = 70
}

module "cicd" {
  source = "../../modules/ecs-cicd-ghapps"

  service_name = var.service_name
  cluster_name = local.cluster_info.cluster_name

  network_info = local.network_info
  ecs_info     = local.cluster_info

  s3_bucket_artf = local.s3_artifact_bucket

  repository_id = "levi-x00/base-service"
  branch_name   = "master"
}

####################################################################
# output section
####################################################################
output "service_name" {
  value = module.service.service_name
}
