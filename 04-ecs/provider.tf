terraform {

  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.70.0"
    }
  }
  required_version = ">=1.5.0"
}

provider "aws" {
  region  = local.aws_region
  profile = var.aws_profile

  default_tags {
    tags = {
      Environment = var.environment
      Application = var.application
    }
  }
}
