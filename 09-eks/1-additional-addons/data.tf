data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "s3-backend-tfstate-l32yrpi"
    key    = "dev/eks-stack.tfstate"
    region = "us-east-1"
  }
}

data "aws_eks_cluster_auth" "cluster" {
  name = data.terraform_remote_state.eks.outputs.cluster_id
}

locals {

  eks_tfstate  = data.terraform_remote_state.eks.outputs
  cluster_name = local.eks_tfstate.cluster_id

  openid_connect_provider_cluster_arn = local.eks_tfstate.openid_connect_provider_cluster_arn
  openid_connect_provider_cluster_url = local.eks_tfstate.openid_connect_provider_cluster_url

}
