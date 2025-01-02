terraform {

  backend "s3" {
    bucket         = "s3-backend-tfstate-ae16zls"
    key            = "dev/network.tfstate"
    region         = "us-east-1"
    dynamodb_table = "dynamodb-lock-table-ae16zls"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60.0"
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
