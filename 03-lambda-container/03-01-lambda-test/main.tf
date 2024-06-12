###################### variables section ######################
variable "region" {
  default = "us-east-1"
}

variable "tags" {
  default = {
    Environment = "dev"
    Application = "devops-app"
  }
}

###################### provider section #######################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0.0"
    }
  }
  required_version = ">=1.5.0"
}

######################## main section ########################

module "lambda-test" {
  source      = "../lambda-module"
  lambda_name = "lambda-ctr-test"

  timeout     = 20
  memory_size = 512

  source_dir = "${path.module}/src"

  security_group_ids = []
  subnet_ids         = []

  lambda_inline_policy = data.aws_iam_policy_document.inline_policy.json

  tags = var.tags
}
