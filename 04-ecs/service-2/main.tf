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
    }
  }
}

#####################################################################
# main service
#####################################################################
module "service" {
  source = "../../modules/ecs-task/fargate-cm"

  service_name     = var.service_name
  docker_file_path = "${path.module}/src"

  cpu    = var.cpu
  memory = var.memory
  port   = var.port

  path_pattern = "/${var.service_name}"

  cluster_info = local.cluster_info
  network_info = local.network_info

  min_capacity = 1
  max_capacity = 1

  cpu_target_value = 85
  mem_target_value = 85

}

#####################################################################
# CI/CD
#####################################################################
module "cicd" {
  source = "../../modules/ecs-cicd-ghapps"

  service_name = var.service_name

  cluster_name   = local.cluster_name
  s3_bucket_artf = local.s3_bucket_artf

  network_info = local.network_info
  ecs_info     = local.cluster_info

  repository_id = "levi-x00/service-2"
  branch_name   = "master"
}

#####################################################################
# output section
#####################################################################
output "service_name" {
  value = module.service.service_name
}
