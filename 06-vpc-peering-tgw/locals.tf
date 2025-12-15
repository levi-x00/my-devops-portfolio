data "aws_availability_zones" "azs" {
  state = "available"
}

locals {

  ec2_inbound_ports = ["22", "443"]
  ep_inbound_ports  = ["443"]

  azs = data.aws_availability_zones.azs.names
}
