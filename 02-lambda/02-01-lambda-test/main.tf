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
      version = "~> 5.60.0"
    }
  }
  required_version = ">=1.6.0"
}

######################## main section ########################

module "lambda-test" {
  source      = "../modules/lambda"
  lambda_name = "lambda-test"

  runtime     = "python3.9"
  timeout     = 20
  memory_size = 256
  handler     = "lambda_function.lambda_handler"

  source_dir = "${path.module}/src"
  output_dir = "${path.module}/archived"

  security_group_ids = []
  subnet_ids         = []

  lambda_inline_policy = data.aws_iam_policy_document.inline_policy.json

  tags = var.tags
}
