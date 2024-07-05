terraform {
  backend "s3" {
    bucket         = "s3-backend-tfstate-hd47u4l"
    key            = "dev/eks-stack.tfstate"
    region         = "us-east-1"
    dynamodb_table = "dynamodb-lock-table-hd47u4l"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.9"
    }

    http = {
      source  = "hashicorp/http"
      version = "~> 3.3"
    }
  }
  required_version = ">=1.5.0"
}

provider "http" {
  # Configuration options
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


