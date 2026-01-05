output "transit_gateway_id" {
  description = "ID of the Transit Gateway"
  value       = aws_ec2_transit_gateway.main.id
}

output "cloud_vpc_id" {
  description = "ID of the Cloud VPC"
  value       = module.cloud_vpc.vpc_id
}

output "onprem_vpc_id" {
  description = "ID of the OnPrem VPC"
  value       = module.on_prem_vpc.vpc_id
}

output "router1_public_ip" {
  description = "Public IP of Router1"
  value       = aws_eip.router1.public_ip
}

output "router2_public_ip" {
  description = "Public IP of Router2"
  value       = aws_eip.router2.public_ip
}

output "router1_private_ip" {
  description = "Private IP of Router1"
  value       = aws_instance.onprem_router1.private_ip
}

output "router2_private_ip" {
  description = "Private IP of Router2"
  value       = aws_instance.onprem_router2.private_ip
}

output "cloud_ec2_a_private_ip" {
  description = "Private IP of Cloud EC2 A"
  value       = aws_instance.cloud_ec2_a.private_ip
}

output "onprem_server1_private_ip" {
  description = "Private IP of OnPrem Server 1"
  value       = aws_instance.onprem_server1.private_ip
}

output "onprem_server2_private_ip" {
  description = "Private IP of OnPrem Server 2"
  value       = aws_instance.onprem_server2.private_ip
}
