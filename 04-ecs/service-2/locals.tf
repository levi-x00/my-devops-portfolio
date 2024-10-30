locals {
  cluster_info = data.terraform_remote_state.cluster.outputs
  network_info = data.terraform_remote_state.network.outputs

  http_listener_arn = local.cluster_info.http_internal_listener_arn
}
