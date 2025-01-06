locals {
  cluster_name = var.cluster_name

  kms_key_id     = data.terraform_remote_state.network.outputs.kms_key_id
  kms_key_arn    = data.terraform_remote_state.network.outputs.kms_key_arn
  vpc_id         = data.terraform_remote_state.network.outputs.vpc_id
  lb_subnets     = data.terraform_remote_state.network.outputs.public_subnet_ids
  prv_subnets    = data.terraform_remote_state.network.outputs.private_subnet_ids
  vpc_cidr_block = data.terraform_remote_state.network.outputs.vpc_cidr_block
  account_id     = data.aws_caller_identity.current.account_id

  aws_iam_oidc_connect_provider_extract_from_arn = element(split("oidc-provider/", "${aws_iam_openid_connect_provider.eks.arn}"), 1)
}
