data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "s3-backend-tfstate-5180c5z"
    key    = "dev/eks-stack.tfstate"
    region = "us-east-1"
  }
}

locals {
  cluster_name = data.terraform_remote_state.eks.outputs.cluster_id
}
