data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket  = var.tfstate_bucket
    key     = var.network_tfstate_key
    region  = var.aws_region
    profile = var.aws_profile
  }
}

data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket  = var.tfstate_bucket
    key     = var.eks_tfstate_key
    region  = var.aws_region
    profile = var.aws_profile
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
