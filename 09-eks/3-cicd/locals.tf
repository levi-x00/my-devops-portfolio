locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.region

  network_info = data.terraform_remote_state.network.outputs
  kms_key_arn  = local.network_info.kms_key_arn

  eks_info     = data.terraform_remote_state.eks.outputs
  cluster_name = local.eks_info.cluster_id
  cluster_arn  = local.eks_info.cluster_arn

  codebuild_role_arn = local.eks_info.codebuild_role_arn
}
