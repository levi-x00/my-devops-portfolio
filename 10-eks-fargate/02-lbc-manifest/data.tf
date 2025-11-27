# Terraform Remote State Datasource - Remote Backend AWS S3 for eks stack
data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket  = var.tfstate_bucket
    key     = var.eks_tfstate_key
    region  = var.aws_region
    profile = var.aws_profile
  }
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket  = var.tfstate_bucket
    key     = var.network_tfstate_key
    region  = var.aws_region
    profile = var.aws_profile
  }
}

# Datasource: AWS Load Balancer Controller IAM Policy get from aws-load-balancer-controller/ GIT Repo (latest)
data "http" "lbc_iam_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json"

  request_headers = {
    Accept = "application/json"
  }
}

# Datasource: EKS Cluster Auth 
data "aws_eks_cluster_auth" "cluster" {
  name = local.cluster_id
}
