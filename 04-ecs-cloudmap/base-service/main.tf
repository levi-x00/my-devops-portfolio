############### provider section ##################
terraform {
  backend "s3" {
    bucket         = "s3-backend-tfstate-822xx2w"
    key            = "dev/main-svc-stack.tfstate"
    region         = "us-east-1"
    dynamodb_table = "dynamodb-lock-table-822xx2w"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0.0"
    }
  }
  required_version = ">=1.5.0"
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Environment = var.environment
      Application = var.application
      Purpose     = "DevOps Projects"
    }
  }
}

#-----------------------------------------------------------------------------------
# main service section
#-----------------------------------------------------------------------------------
module "service" {
  source = "../../modules/ecs-task/fargate-cm"

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
}

module "cicd" {
  source = "../../modules/cicd-pipeline"

  service_name    = var.service_name
  repository_name = "${var.service_name}-repo"
  cluster_name    = data.terraform_remote_state.cluster.outputs.cluster_name
  s3_bucket_artf  = data.terraform_remote_state.cluster.outputs.s3_artifact_bucket
  network_info    = data.terraform_remote_state.network.outputs
}

############### output section ##################
output "service_name" {
  value = module.service.service_name
}
