#####################################################################
# network and ECS cluster tfstate section
#####################################################################
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "s3-backend-tfstate-23jap3k"
    key    = "dev/network.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "cluster" {
  backend = "s3"
  config = {
    bucket = "s3-backend-tfstate-23jap3k"
    key    = "dev/ecs-stack.tfstate"
    region = "us-east-1"
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
