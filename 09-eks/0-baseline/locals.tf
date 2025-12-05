locals {
  tag_resource_types = [
    "instance",
    "network-interface",
    "volume"
  ]

  network_info = data.terraform_remote_state.network.outputs
  kms_key_arn  = local.network_info.kms_key_arn

  vpc_id = local.network_info.vpc_id

  private_subnet_ids = local.network_info.private_subnet_ids
}
