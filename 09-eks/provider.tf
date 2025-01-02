terraform {

  backend "s3" {
    bucket         = "s3-backend-tfstate-ae16zls"
    key            = "dev/eks-stack.tfstate"
    region         = "us-east-1"
    dynamodb_table = "dynamodb-lock-table-ae16zls"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.53"
    }
  }
  required_version = ">=1.6.0"
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
