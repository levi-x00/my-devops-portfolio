data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id

  vpc_endpoints = {
    "ec2"           = "com.amazonaws.${var.aws_region}.ec2"
    "ssm"           = "com.amazonaws.${var.aws_region}.ssm"
    "ssmmessages"   = "com.amazonaws.${var.aws_region}.ssmmessages"
    "ec2messages"   = "com.amazonaws.${var.aws_region}.ec2messages"
    "ecs-agent"     = "com.amazonaws.${var.aws_region}.ecs-agent"
    "ecs"           = "com.amazonaws.${var.aws_region}.ecs"
    "ecs-telemetry" = "com.amazonaws.${var.aws_region}.ecs-telemetry"
  }
}
