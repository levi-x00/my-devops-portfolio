data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "s3-backend-tfstate-djnf2a8"
    key    = "${var.environment}/network.tfstate"
    region = "us-east-1"
  }
}

data "aws_caller_identity" "current" {}

data "aws_iam_roles" "ecs" {
  name_regex  = "AWSServiceRoleFor*"
  path_prefix = "/aws-service-role/ecs.amazonaws.com/"
}

data "aws_route53_zone" "selected" {
  name         = local.public_domain
  private_zone = false
}
