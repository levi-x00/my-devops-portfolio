locals {
  eks_info = data.terraform_remote_state.eks.outputs
  vpc_info = data.terraform_remote_state.network.outputs

  cluster_endpoint = local.eks_info.cluster_endpoint
  cluster_ca       = local.eks_info.cluster_ca

  cluster_id = local.eks_info.cluster_id
  vpc_id     = local.vpc_info.vpc_id

  iam_openid_conn_provider_arn = local.eks_info.aws_iam_openid_connect_provider_extract_from_arn
}
