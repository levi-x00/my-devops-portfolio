terraform {
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
