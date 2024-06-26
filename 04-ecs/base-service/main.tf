############### remote tfstate ####################
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "s3-backend-tfstate-djnf2a8"
    key    = "${var.environment}/network.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "cluster" {
  backend = "s3"
  config = {
    bucket = "s3-backend-tfstate-djnf2a8"
    key    = "${var.environment}/ecs-stack.tfstate"
    region = "us-east-1"
  }
}

############### provider section ##################
terraform {
  backend "s3" {
    bucket         = "s3-backend-tfstate-djnf2a8"
    key            = "${var.environment}/main-svc-stack.tfstate"
    region         = "us-east-1"
    dynamodb_table = "dynamodb-lock-table-djnf2a8"
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
      Owner       = "Levi"
    }
  }
}

############### main section ##################
module "service" {
  source = "../../modules/ecs-task/fargate"

  service_name = var.service_name
  region       = var.region
  environment  = var.environment
  application  = var.application

  docker_file_path = "${path.module}/src"

  retention_days = var.cw_logs_retention_days
  cpu            = var.cpu
  memory         = var.memory
  port           = 5000

  cluster_info = data.terraform_remote_state.cluster.outputs
  network_info = data.terraform_remote_state.network.outputs

}

############### output section ##################
output "service_name" {
  value = module.service.service_name
}
