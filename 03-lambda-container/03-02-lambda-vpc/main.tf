##################### remote tfstate ##########################
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "s3-backend-tfstate-djnf2a8"
    key    = "${var.environment}/network.tfstate"
    region = "us-east-1"
  }
}

###################### variables section ######################
variable "environment" {
  default = "dev"
}

variable "lambda_name" {
  default = "lambda-vpc-cont-test"
}

variable "region" {
  default = "us-east-1"
}

variable "tags" {
  default = {
    Environment = "dev"
    Application = "devops-app"
  }
}

###################### local section ##########################
locals {
  network            = data.terraform_remote_state.network.outputs
  vpc_id             = local.network.vpc_id
  private_subnet_ids = local.network.private_subnet_ids

  lambda_inline_policy = data.aws_iam_policy_document.inline_policy.json
}

###################### provider section #######################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60.0"
    }
  }
  required_version = ">=1.6.0"
}

resource "aws_security_group" "lambda_sg" {
  vpc_id = local.vpc_id

  name = "${var.lambda_name}-sg"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.lambda_name}-sg"
  }
}

######################## main section ########################
module "lambda-test" {
  source      = "../modules/lambda-container"
  lambda_name = var.lambda_name
  timeout     = 20
  memory_size = 512
  source_dir  = "${path.module}/src"

  security_group_ids = [aws_security_group.lambda_sg.id]
  subnet_ids         = local.private_subnet_ids

  lambda_inline_policy = local.lambda_inline_policy

  tags = var.tags
}
