#####################################################################
# network and ECS cluster tfstate section
#####################################################################
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket  = var.tfstate_bucket
    key     = var.tfstate_network_key
    region  = var.aws_region
    profile = var.aws_profile
  }
}

data "terraform_remote_state" "cluster" {
  backend = "s3"
  config = {
    bucket  = var.tfstate_bucket
    key     = var.tfstate_ecs_key
    region  = var.aws_region
    profile = var.aws_profile
  }
}

#####################################################################
# local section
#####################################################################
locals {
  cluster_info = data.terraform_remote_state.cluster.outputs
  network_info = data.terraform_remote_state.network.outputs

  listener_arn = local.cluster_info.https_listener_arn

  s3_artifact_bucket = data.terraform_remote_state.cluster.outputs.s3_artifact_bucket
}
