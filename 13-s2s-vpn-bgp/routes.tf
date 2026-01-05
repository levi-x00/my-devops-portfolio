#########################################################################
# On-Prem VPC Routes
#########################################################################

# Route from on-prem private subnet 1 to AWS via Router 1
resource "aws_route" "onprem_private1_to_aws" {
  route_table_id         = module.on_prem_vpc.private_rtb_id
  destination_cidr_block = "10.16.0.0/16"
  network_interface_id   = aws_network_interface.router1_private.id
}

# Note: The CloudFormation template has separate route tables for each private subnet
# If your VPC module creates separate route tables, you'll need to adjust this
# For now, assuming a single private route table
