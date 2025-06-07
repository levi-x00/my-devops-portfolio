data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "s3-backend-tfstate-l32yrpi"
    key    = "dev/network.tfstate"
    region = var.region
  }
}

data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
data "aws_ssm_parameter" "eks_al2023" {
  name            = "/aws/service/eks/optimized-ami/${var.cluster_version}/amazon-linux-2023/x86_64/standard/recommended/image_id"
  with_decryption = true
}

data "tls_certificate" "cluster" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}
