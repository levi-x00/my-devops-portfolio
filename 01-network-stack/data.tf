data "aws_availability_zones" "azs" {
  state = "available"
}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id

  vpc_endpoints = {
    "ec2"           = "com.amazonaws.${var.region}.ec2"
    "ssm"           = "com.amazonaws.${var.region}.ssm"
    "ssmmessages"   = "com.amazonaws.${var.region}.ssmmessages"
    "ec2messages"   = "com.amazonaws.${var.region}.ec2messages"
    "ecs-agent"     = "com.amazonaws.${var.region}.ecs-agent"
    "ecs"           = "com.amazonaws.${var.region}.ecs"
    "ecs-telemetry" = "com.amazonaws.${var.region}.ecs-telemetry"
  }
}
