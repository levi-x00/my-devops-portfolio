locals {
  cluster_info = data.terraform_remote_state.cluster.outputs
  network_info = data.terraform_remote_state.network.outputs
}
