locals {
  network_info = data.terraform_remote_state.network.outputs

  vpc_id     = local.network_info.vpc_id
  subnet_ids = local.network_info.private_subnet_ids
}
