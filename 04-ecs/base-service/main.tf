terraform {
  backend "s3" {}
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0.0"
    }
  }
  required_version = ">=1.5.0"
}

provider "aws" {
  region = var.aws_region

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

  lb_sg_id     = local.cluster_info.lb_sg_id
  cluster_info = local.cluster_info
  network_info = local.network_info

  min_capacity = 1
  max_capacity = 1

  target_value = 70
}

module "cicd" {
  source = "../../modules/ecs-cicd"

  service_name    = var.service_name
  repository_name = "${var.service_name}-repo"
  cluster_name    = data.terraform_remote_state.cluster.outputs.cluster_name
  s3_bucket_artf  = data.terraform_remote_state.cluster.outputs.s3_artifact_bucket
  network_info    = data.terraform_remote_state.network.outputs
  ecs_info        = data.terraform_remote_state.cluster.outputs
}

############### output section ##################
output "service_name" {
  value = module.service.service_name
}
