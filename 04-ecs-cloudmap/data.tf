data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = var.s3_config_bucket
    key    = "${var.environment}/network.tfstate"
    region = var.region
  }
}

data "aws_elb_service_account" "lb" {}
data "aws_caller_identity" "current" {}
