########################################################################
# mixed locals and data source in terraform, update the tfremote state network
########################################################################

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket  = var.tfstate_bucket
    key     = var.tfstate_key
    region  = var.aws_region
    profile = var.aws_profile
  }
}

data "aws_elb_service_account" "lb" {}
data "aws_caller_identity" "current" {}

locals {

  kms_key_id  = data.terraform_remote_state.network.outputs.kms_key_id
  kms_key_arn = data.terraform_remote_state.network.outputs.kms_key_arn
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  public_subnet_ids  = data.terraform_remote_state.network.outputs.public_subnet_ids
  private_subnet_ids = data.terraform_remote_state.network.outputs.private_subnet_ids

  vpc_cidr_block = data.terraform_remote_state.network.outputs.vpc_cidr_block
  account_id     = data.aws_caller_identity.current.account_id
}
