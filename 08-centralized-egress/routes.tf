resource "aws_route" "pub_egress_to_spoke01" {
  destination_cidr_block = var.spoke01_cidr_block
  route_table_id         = module.egress_vpc.public_rt_id
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "pub_egress_to_spoke02" {
  destination_cidr_block = var.spoke02_cidr_block
  route_table_id         = module.egress_vpc.public_rt_id
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "prv1_egress_to_spoke01" {
  destination_cidr_block = var.spoke01_cidr_block
  route_table_id         = module.egress_vpc.private1_rt_id
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "prv1_egress_to_spoke02" {
  destination_cidr_block = var.spoke02_cidr_block
  route_table_id         = module.egress_vpc.private1_rt_id
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "prv2_egress_to_spoke01" {
  destination_cidr_block = var.spoke01_cidr_block
  route_table_id         = module.egress_vpc.private2_rt_id
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "prv2_egress_to_spoke02" {
  destination_cidr_block = var.spoke02_cidr_block
  route_table_id         = module.egress_vpc.private2_rt_id
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "spoke01_to_egress" {
  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.spoke01_vpc
  ]

  route_table_id         = module.spoke1_vpc.private_rt_id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "spoke02_to_egress" {
  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.spoke02_vpc
  ]
  route_table_id         = module.spoke2_vpc.private_rt_id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}
