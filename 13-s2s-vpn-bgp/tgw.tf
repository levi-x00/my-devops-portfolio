#########################################################################
# Transit Gateway
#########################################################################
resource "aws_ec2_transit_gateway" "main" {
  description = "Main Transit Gateway for S2S VPN"
  
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  
  tags = {
    Name = "main-tgw"
  }
}

#########################################################################
# Transit Gateway VPC Attachments
#########################################################################
resource "aws_ec2_transit_gateway_vpc_attachment" "cloud_vpc" {
  subnet_ids         = module.cloud_vpc.private_subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = module.cloud_vpc.vpc_id
  
  tags = {
    Name = "cloud-vpc-attachment"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "onprem_vpc" {
  subnet_ids         = module.on_prem_vpc.private_subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = module.on_prem_vpc.vpc_id
  
  tags = {
    Name = "onprem-vpc-attachment"
  }
}

#########################################################################
# Customer Gateway
#########################################################################
resource "aws_customer_gateway" "main" {
  bgp_asn    = 65000
  ip_address = aws_eip.onprem_router.public_ip
  type       = "ipsec.1"
  
  tags = {
    Name = "main-cgw"
  }
  
  depends_on = [aws_instance.onprem_router]
}

#########################################################################
# VPN Gateway
#########################################################################
resource "aws_vpn_gateway" "main" {
  vpc_id = module.cloud_vpc.vpc_id
  
  tags = {
    Name = "main-vgw"
  }
}

#########################################################################
# Site-to-Site VPN Connection
#########################################################################
resource "aws_vpn_connection" "main" {
  customer_gateway_id = aws_customer_gateway.main.id
  transit_gateway_id  = aws_ec2_transit_gateway.main.id
  type               = "ipsec.1"
  static_routes_only = false
  
  tags = {
    Name = "main-s2s-vpn"
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