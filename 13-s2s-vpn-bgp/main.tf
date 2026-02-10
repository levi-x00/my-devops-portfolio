#########################################################################
# VPC Cloud (AWS Side)
#########################################################################
module "cloud_vpc" {
  source = "../modules/vpc"

  vpc_name = "cloud-vpc"

  vpc_cidr_block = "10.16.0.0/16"

  private_subnet_cidra = "10.16.32.0/20"
  private_subnet_cidrb = "10.16.96.0/20"

  public_subnet_cidra = "10.16.0.0/20"
  public_subnet_cidrb = "10.16.64.0/20"

  multi_az_nat = false
  enable_nat   = true
  create_igw   = true

  tags = {
    Name = "cloud-vpc"
  }
}

#########################################################################
# VPC On-Premises (Simulated)
#########################################################################
module "on_prem_vpc" {
  source   = "../modules/vpc"
  vpc_name = "on-prem-vpc"

  vpc_cidr_block = "192.168.8.0/21"

  private_subnet_cidra = "192.168.10.0/24"
  private_subnet_cidrb = "192.168.11.0/24"

  public_subnet_cidra = "192.168.12.0/24"
  public_subnet_cidrb = "192.168.13.0/24"

  multi_az_nat = false
  enable_nat   = true
  create_igw   = true

  tags = {
    Name = "on-prem-vpc"
  }
}

# #########################################################################
# # VPN 1
# #########################################################################
# resource "aws_customer_gateway" "cgw1" {
#   bgp_asn    = "65016"
#   ip_address = aws_eip.router1.public_ip
#   type       = "ipsec.1"

#   tags = {
#     Name = "${var.environment}-cgw1"
#   }
# }

# resource "aws_vpn_connection" "vpn1" {
#   customer_gateway_id = aws_customer_gateway.cgw1.id
#   transit_gateway_id  = aws_ec2_transit_gateway.main.id
#   static_routes_only  = true

#   type = aws_customer_gateway.cgw1.type

#   tags = {
#     Name = "${var.environment}-vpn1"
#   }
# }

#########################################################################
# VPN 2
#########################################################################
# resource "aws_customer_gateway" "cgw2" {
#   bgp_asn    = "65016"
#   ip_address = aws_eip.onprem_eip2.public_ip
#   type       = "ipsec.1"

#   tags = {
#     Name = "${var.environment}-cgw2"
#   }
# }

# resource "aws_vpn_connection" "vpn2" {
#   customer_gateway_id = aws_customer_gateway.cgw2.id
#   transit_gateway_id  = aws_ec2_transit_gateway.main.id
#   type                = aws_customer_gateway.cgw2.type
# }
