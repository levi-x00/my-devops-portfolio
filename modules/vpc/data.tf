data "aws_availability_zones" "azs" {
  state = "available"
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  region = data.aws_region.current.name

  private_rtb_name = var.multi_az_nat == true ? "${var.vpc_name}-private-rtb" : "${var.vpc_name}-private-rtb1"
  private_rtb_azb  = var.multi_az_nat == true ? aws_route_table.private2[0].id : aws_route_table.private1[0].id
}
