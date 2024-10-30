#-----------------------------------------------------------------------------------
# backend tfstate section
#-----------------------------------------------------------------------------------
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "s3-backend-tfstate-822xx2w"
    key    = "dev/network.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "cluster" {
  backend = "s3"
  config = {
    bucket = "s3-backend-tfstate-822xx2w"
    key    = "dev/ecs-stack.tfstate"
    region = "us-east-1"
  }
}