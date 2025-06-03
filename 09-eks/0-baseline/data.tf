data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "s3-backend-tfstate-5180c5z"
    key    = "dev/network.tfstate"
    region = var.region
  }
}

data "aws_caller_identity" "current" {}
