data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "s3-backend-tfstate-3vmnj35"
    key    = "dev/network.tfstate"
    region = "us-east-1"
  }
}
data "aws_elb_service_account" "lb" {}
data "aws_caller_identity" "current" {}
