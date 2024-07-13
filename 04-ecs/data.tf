data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "s3-backend-tfstate-cr2krz3"
    key    = "dev/network.tfstate"
    region = "us-east-1"
  }
}

data "aws_caller_identity" "current" {}

data "aws_route53_zone" "selected" {
  name         = local.public_domain
  private_zone = false
}
