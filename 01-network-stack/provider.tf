terraform {

  backend "s3" {
    bucket       = "s3-backend-tfstate-cy75t0o"
    key          = "dev/network.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
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
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Application = var.application
    }
  }
}
