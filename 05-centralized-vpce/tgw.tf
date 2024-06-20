resource "aws_ec2_transit_gateway" "mytgw" {
  description = "centralize vpce demo"

  # default_route_table_association = false
  # default_route_table_propagation = false

  tags = {
    Name = "vpce-tgw"
  }
}

# resource "aws_ec2_transit_gateway_route_table" "tgw_rt" {
#   transit_gateway_id = aws_ec2_transit_gateway.mytgw.id
#   tags = {
#     Name = "vpce-tgw-rt"
#   }
# }

resource "aws_ec2_transit_gateway_vpc_attachment" "central_vpce" {
  subnet_ids         = module.vpc_vpce.public_subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.mytgw.id
  vpc_id             = module.vpc_vpce.vpc_id

  tags = {
    Name = "vpce-vpc-attachment"
  }
}

# resource "aws_ec2_transit_gateway_route_table_association" "central_vpce" {
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.central_vpce.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_rt.id
# }

resource "aws_ec2_transit_gateway_vpc_attachment" "spoke1" {
  subnet_ids         = module.vpc_spoke1.public_subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.mytgw.id
  vpc_id             = module.vpc_spoke1.vpc_id

  tags = {
    Name = "spoke1-vpc-attachment"
  }
}

# resource "aws_ec2_transit_gateway_route_table_association" "spoke1" {
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke1.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_rt.id
# }

resource "aws_ec2_transit_gateway_vpc_attachment" "spoke2" {
  subnet_ids         = module.vpc_spoke2.public_subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.mytgw.id
  vpc_id             = module.vpc_spoke2.vpc_id

  tags = {
    Name = "spoke2-vpc-attachment"
  }
}

# resource "aws_ec2_transit_gateway_route_table_association" "spoke2" {
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke2.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_rt.id
# }
