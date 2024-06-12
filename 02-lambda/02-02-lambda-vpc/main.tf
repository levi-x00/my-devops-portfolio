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

module "lambda-vpc-test" {
  source      = "../lambda-module"
  lambda_name = var.lambda_name

  runtime     = "python3.9"
  timeout     = 20
  memory_size = 256
  handler     = "lambda_function.lambda_handler"

  source_dir = "${path.module}/src"
  output_dir = "${path.module}/archived"

  security_group_ids = [aws_security_group.this.id]
  subnet_ids         = local.private_subnet_ids

  lambda_inline_policy = data.aws_iam_policy_document.inline_policy.json

  tags = var.tags
}
