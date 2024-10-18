#-----------------------------------------------------------------------------------
# remote tfstate
#-----------------------------------------------------------------------------------
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "s3-backend-tfstate-822xx2w"
    key    = "dev/network.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "cluster" {
  backend = "s3"
  config = {
    bucket = "s3-backend-tfstate-822xx2w"
    key    = "dev/ecs-stack.tfstate"
    region = "us-east-1"
  }
}

#-----------------------------------------------------------------------------------
# provider section
#-----------------------------------------------------------------------------------
terraform {
  backend "s3" {
    bucket         = "s3-backend-tfstate-822xx2w"
    key            = "dev/ecs-service1-stack.tfstate"
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
    }
  }
}

#-----------------------------------------------------------------------------------
# main section
#-----------------------------------------------------------------------------------

module "service" {
  source = "../../modules/ecs-task/ec2"

  service_name   = var.service_name
  retention_days = 60

  docker_file_path = "${path.module}/src"

  memory = var.memory
  cpu    = var.cpu
  port   = var.port

  desired_count = 2
  cluster_info  = data.terraform_remote_state.cluster.outputs
  network_info  = data.terraform_remote_state.network.outputs
  path_pattern  = "/${var.service_name}"

  listener_arn = data.terraform_remote_state.cluster.outputs.int_https_listener_arn
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
