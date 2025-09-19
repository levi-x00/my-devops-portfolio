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

data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }

  owners = ["amazon"]
}

data "template_file" "user_data" {
  template = file("user_data.sh")

  vars = {
    ecs_cluster_name = aws_ecs_cluster.cluster.name
  }
}


locals {
  network_info = data.terraform_remote_state.network.outputs

  kms_key_id  = local.network_info.kms_key_id
  kms_key_arn = local.network_info.kms_key_arn
  vpc_id      = local.network_info.vpc_id

  public_subnet_ids  = local.network_info.public_subnet_ids
  private_subnet_ids = local.network_info.private_subnet_ids

  vpc_cidr_block = local.network_info.vpc_cidr_block
  aws_region     = local.network_info.aws_region

  account_id = local.network_info.account_id
}
