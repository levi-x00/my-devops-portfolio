terraform {
  backend "s3" {
    bucket       = "s3-backend-tfstate-5180c5z"
    key          = "dev/eks-additional-stuffs.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.94"
    }

    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">= 3.1.0"
    }

    http = {
      source  = "hashicorp/http"
      version = ">= 3.4.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.35.0"
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

provider "http" {}

provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}
