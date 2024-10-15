locals {
  cluster_name = var.cluster_name

  kms_key_id  = data.terraform_remote_state.network.outputs.kms_key_id
  kms_key_arn = data.terraform_remote_state.network.outputs.kms_key_arn
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id
  lb_subnets  = data.terraform_remote_state.network.outputs.public_subnet_ids
  prv_subnets = data.terraform_remote_state.network.outputs.private_subnet_ids
  account_id  = data.aws_caller_identity.current.account_id
}
