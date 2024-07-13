############### remote tfstate ####################
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "s3-backend-tfstate-cr2krz3"
    key    = "dev/network.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "cluster" {
  backend = "s3"
  config = {
    bucket = "s3-backend-tfstate-cr2krz3"
    key    = "dev/ecs-stack.tfstate"
    region = "us-east-1"
  }
}

############### provider section ##################
terraform {
  backend "s3" {
    bucket         = "s3-backend-tfstate-cr2krz3"
    key            = "dev/ecs-service1-stack.tfstate"
    region         = "us-east-1"
    dynamodb_table = "dynamodb-lock-table-cr2krz3"
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

############### main section ##################
module "service" {
  source = "../../modules/ecs-task/fargate"

  service_name     = var.service_name
  docker_file_path = "${path.module}/src"

  cpu          = var.cpu
  memory       = var.memory
  port         = var.port
  path_pattern = "/${var.service_name}"

  cluster_info = data.terraform_remote_state.cluster.outputs
  network_info = data.terraform_remote_state.network.outputs
}

############### output section ##################
output "service_name" {
  value = module.service.service_name
}
