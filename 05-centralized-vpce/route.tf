# ============ spoke 1 <-> vpce VPC ================
resource "aws_route" "spoke1_vpce" {
  route_table_id         = module.vpc_spoke1.private_rt_id
  destination_cidr_block = var.vpc_vpce_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.mytgw.id
}

resource "aws_route" "vpce_spoke1" {
  route_table_id         = module.vpce.private_rt_id
  destination_cidr_block = var.vpc_spoke1_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.mytgw.id
}

# ============ spoke 2 <-> vpce VPC ================
resource "aws_route" "spoke2_vpce" {
  route_table_id         = module.vpc_spoke2.private_rt_id
  destination_cidr_block = var.vpc_vpce_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.mytgw.id
}

resource "aws_route" "vpce_spoke2" {
  route_table_id         = module.vpce.private_rt_id
  destination_cidr_block = var.vpc_spoke2_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.mytgw.id
}
