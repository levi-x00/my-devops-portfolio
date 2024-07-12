data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {

  network = var.network_info

  kms_key_id      = local.network.kms_key_id
  kms_key_arn     = local.network.kms_key_arn
  vpc_id          = local.network.vpc_id
  public_subnets  = local.network.public_subnet_ids
  private_subnets = local.network.private_subnet_ids
  codebuild_sg_id = local.network.codebuild_sg_id

  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
}
