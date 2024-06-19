# ============ spoke 1 <-> vpce VPC ================
resource "aws_route" "spoke1_vpce" {
  route_table_id            = module.vpc_spoke1.private_rt_id
  destination_cidr_block    = var.vpc_spoke1_cidr
  vpc_peering_connection_id = "pcx-45ff3dc1"
}

resource "aws_route" "vpce_spoke1" {
  route_table_id            = aws_route_table.testing.id
  destination_cidr_block    = var.vpc_vpce_cidr
  vpc_peering_connection_id = "pcx-45ff3dc1"
}
