terraform {
  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.1.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.5.0"
    }
  }
  required_version = ">=1.6.0"
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

data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.this.id
}

provider "helm" {
  kubernetes = {
    host  = aws_eks_cluster.this.endpoint
    token = data.aws_eks_cluster_auth.cluster.token

    cluster_ca_certificate = base64decode(aws_eks_cluster.this.certificate_authority[0].data)
  }
}

provider "kubernetes" {
  host  = aws_eks_cluster.this.endpoint
  token = data.aws_eks_cluster_auth.cluster.token

  cluster_ca_certificate = base64decode(aws_eks_cluster.this.certificate_authority[0].data)
}
