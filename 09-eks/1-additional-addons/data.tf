data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "s3-backend-tfstate-5180c5z"
    key    = "dev/eks-stack.tfstate"
    region = "us-east-1"
  }
}

data "aws_eks_cluster_auth" "cluster" {
  name = data.terraform_remote_state.eks.outputs.cluster_id
}

data "http" "lbc_iam_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json"
  request_headers = {
    Accept = "application/json"
  }
}

locals {

  eks_tfstate  = data.terraform_remote_state.eks.outputs
  cluster_name = local.eks_tfstate.cluster_id

  cluster_vpc_id = local.eks_tfstate.cluster_vpc_id

  openid_connect_provider_cluster_arn = local.eks_tfstate.openid_connect_provider_cluster_arn
  openid_connect_provider_cluster_url = local.eks_tfstate.openid_connect_provider_cluster_url

}
