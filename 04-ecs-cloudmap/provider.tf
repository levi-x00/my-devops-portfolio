terraform {

  backend "s3" {
    bucket         = "s3-backend-tfstate-lpch2ib"
    key            = "dev/ecs-stack.tfstate"
    region         = "us-east-1"
    dynamodb_table = "dynamodb-lock-table-lpch2ib"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.70.0"
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
