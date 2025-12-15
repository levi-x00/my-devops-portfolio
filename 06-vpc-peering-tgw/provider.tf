terraform {
  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.94"
    }
  }
  required_version = ">=1.6.0"
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile

  default_tags {
    tags = {
      CreatedBy   = "terraform"
      Environment = "prd"
    }
  }
}
