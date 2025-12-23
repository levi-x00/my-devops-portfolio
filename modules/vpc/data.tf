data "aws_availability_zones" "azs" {
  state = "available"
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  region = data.aws_region.current.id

  private_rtb_name = var.multi_az_nat == true ? "${var.vpc_name}-private-rtb1" : "${var.vpc_name}-private-rtb"
}
