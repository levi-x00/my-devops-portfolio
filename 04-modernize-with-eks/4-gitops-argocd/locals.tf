locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.region

  eks_info         = data.terraform_remote_state.eks.outputs
  cluster_name     = local.eks_info.cluster_id
  cluster_endpoint = local.eks_info.cluster_endpoint
  cluster_ca       = local.eks_info.cluster_certificate_authority_data
}
