locals {
  network_info = data.terraform_remote_state.network.outputs

  vpc_id             = local.network_info.vpc_id
  vpc_cidr_block     = local.network_info.vpc_cidr_block
  private_subnet_ids = local.network_info.private_subnet_ids
  kms_key_arn        = local.network_info.kms_key_arn

  account_id    = data.aws_caller_identity.current.account_id
  oidc_provider = replace(aws_iam_openid_connect_provider.eks.url, "https://", "")
}
