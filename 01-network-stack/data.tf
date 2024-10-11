data "aws_availability_zones" "azs" {
  state = "available"
}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}
