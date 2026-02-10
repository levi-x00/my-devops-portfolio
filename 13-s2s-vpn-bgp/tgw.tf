#########################################################################
# Transit Gateway
#########################################################################
resource "aws_ec2_transit_gateway" "main" {
  description     = "s2s vpn with bgp transit gateway"
  amazon_side_asn = 64512

  default_route_table_association = "disable"
  default_route_table_propagation = "enable"

  dns_support      = "enable"
  vpn_ecmp_support = "enable"

  tags = {
    Name = "main-tgw"
  }
}

resource "aws_ec2_transit_gateway_route_table" "cloud_vpc" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id

  tags = {
    Name = "cloud-vpc-tgw-rt"
  }
}

# resource "aws_ec2_transit_gateway_route_table_propagation" "cloud_vpc" {
#   depends_on = [
#     aws_vpn_connection.vpn1
#   ]
#   transit_gateway_attachment_id  = aws_vpn_connection.vpn1.transit_gateway_attachment_id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.cloud_vpc.id
# }

resource "aws_ec2_transit_gateway_route_table_association" "cloud_vpc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.cloud_vpc.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.cloud_vpc.id
}

resource "aws_ec2_transit_gateway_route_table" "on_prem_vpc" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id

  tags = {
    Name = "on-prem-vpc-tgw-rt"
  }
}

resource "aws_ec2_transit_gateway_route_table_propagation" "on_prem_vpc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.cloud_vpc.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.on_prem_vpc.id
}

# resource "aws_ec2_transit_gateway_route_table_association" "vpn1" {
#   depends_on = [
#     aws_vpn_connection.vpn1
#   ]
#   transit_gateway_attachment_id  = aws_vpn_connection.vpn1.transit_gateway_attachment_id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.on_prem_vpc.id
# }

#########################################################################
# Transit Gateway VPC Attachment
#########################################################################
resource "aws_ec2_transit_gateway_vpc_attachment" "cloud_vpc" {
  subnet_ids         = module.cloud_vpc.private_subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = module.cloud_vpc.vpc_id

  tags = {
    Name = "cloud-vpc-tgw-attachment"
  }
}
