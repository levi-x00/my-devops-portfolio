# Terraform Settings Block
terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.31"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.9"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 3.3"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20"
    }
  }

  backend "s3" {
    bucket         = "s3-backend-tfstate-ae16zls"
    key            = "dev/lbc-stack.tfstate"
    region         = "us-east-1"
    dynamodb_table = "dynamodb-lock-table-ae16zls"
  }
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
  kubernetes {
    host                   = local.cluster_endpoint
    cluster_ca_certificate = base64decode(local.cluster_ca)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}
provider "kubernetes" {
  host                   = local.cluster_endpoint
  cluster_ca_certificate = base64decode(local.cluster_ca)
  token                  = data.aws_eks_cluster_auth.cluster.token
}
