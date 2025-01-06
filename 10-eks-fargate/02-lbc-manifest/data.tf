# Terraform Remote State Datasource - Remote Backend AWS S3 for eks stack
data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "s3-backend-tfstate-ae16zls"
    key    = "dev/eks-stack.tfstate"
    region = var.region
  }
}

# Terraform Remote State Datasource - Remote Backend AWS S3 for network stack
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "s3-backend-tfstate-ae16zls"
    key    = "dev/network.tfstate"
    region = "us-east-1"
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
  name = data.terraform_remote_state.eks.outputs.cluster_id
}
