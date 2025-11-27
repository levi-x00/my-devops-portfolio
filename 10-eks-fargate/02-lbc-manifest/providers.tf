# Terraform Settings Block
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.21"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.1.0"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 3.3"
    }
  }

  backend "s3" {}
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile

  default_tags {
    tags = {
      Environment = var.environment
      Application = var.application
    }
  }
}

provider "http" {}
provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}
