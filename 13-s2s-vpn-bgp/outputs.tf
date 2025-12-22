#########################################################################
# Outputs
#########################################################################
output "transit_gateway_id" {
  description = "ID of the Transit Gateway"
  value       = aws_ec2_transit_gateway.main.id
}

output "vpn_connection_id" {
  description = "ID of the VPN Connection"
  value       = aws_vpn_connection.main.id
}

output "customer_gateway_id" {
  description = "ID of the Customer Gateway"
  value       = aws_customer_gateway.main.id
}

output "onprem_router_public_ip" {
  description = "Public IP of the OnPrem Router"
  value       = aws_eip.onprem_router.public_ip
}

output "cloud_vpc_id" {
  description = "ID of the Cloud VPC"
  value       = module.cloud_vpc.vpc_id
}

output "onprem_vpc_id" {
  description = "ID of the OnPrem VPC"
  value       = module.on_prem_vpc.vpc_id
}

output "vpn_tunnel_1_address" {
  description = "The public IP address of the first VPN tunnel"
  value       = aws_vpn_connection.main.tunnel1_address
}

output "vpn_tunnel_2_address" {
  description = "The public IP address of the second VPN tunnel"
  value       = aws_vpn_connection.main.tunnel2_address
}
