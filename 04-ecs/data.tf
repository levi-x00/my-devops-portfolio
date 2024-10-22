data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "s3-backend-tfstate-lnic1rx"
    key    = "dev/network.tfstate"
    region = "us-east-1"
  }
}

data "aws_caller_identity" "current" {}

data "aws_route53_zone" "selected" {
  name         = var.service_domain
  private_zone = false
}
