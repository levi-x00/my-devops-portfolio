locals {
  cluster_name = var.cluster_name
  network_info = data.terraform_remote_state.network.outputs

  kms_key_id     = local.network_info.kms_key_id
  kms_key_arn    = local.network_info.kms_key_arn
  vpc_id         = local.network_info.vpc_id
  lb_subnets     = local.network_info.public_subnet_ids
  prv_subnets    = local.network_info.private_subnet_ids
  vpc_cidr_block = local.network_info.vpc_cidr_block

  account_id = data.aws_caller_identity.current.account_id
}
