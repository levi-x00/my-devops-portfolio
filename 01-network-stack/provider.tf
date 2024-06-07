terraform {

  backend "s3" {
    bucket         = "s3-backend-tfstate-djnf2a8"
    key            = "dev/network.tfstate"
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
  profile = var.profile
  region  = var.region

  default_tags {
    tags = {
      Environment = var.environment
      Application = var.application
    }
  }
}
