locals {
  cluster_info = data.terraform_remote_state.cluster.outputs
  network_info = data.terraform_remote_state.network.outputs

  listener_arn = local.cluster_info.https_listener_arn
}
