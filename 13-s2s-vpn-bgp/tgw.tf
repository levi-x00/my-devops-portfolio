#########################################################################
# Transit Gateway
#########################################################################
resource "aws_ec2_transit_gateway" "main" {
  description                     = "A4LTGW"
  amazon_side_asn                 = 64512
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"

  tags = {
    Name = "main-tgw"
  }
}

#########################################################################
# Transit Gateway VPC Attachment
#########################################################################
resource "aws_ec2_transit_gateway_vpc_attachment" "cloud_vpc" {
  subnet_ids         = module.cloud_vpc.private_subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = module.cloud_vpc.vpc_id

  tags = {
    Name = "A4LTGWATTACHMENT"
  }
}

#########################################################################
# Route Table Updates for Cloud VPC
#########################################################################
resource "aws_route" "cloud_to_tgw" {
  route_table_id         = module.cloud_vpc.private_rtb_id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.main.id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.cloud_vpc]
}
