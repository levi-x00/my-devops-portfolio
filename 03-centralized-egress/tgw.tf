resource "aws_ec2_transit_gateway" "tgw" {
  description = "tgw for centralized egress"

  default_route_table_association = "disable"
  tags = {
    Name = "${var.environment}-tgw"
  }
}

resource "aws_ec2_transit_gateway_route_table" "spoke_rt" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  tags = {
    Name = "${var.environment}-spoke-rt"
  }
}

resource "aws_ec2_transit_gateway_route_table" "egress_rt" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  tags = {
    Name = "${var.environment}-egress-rt"
  }
}

############################### vpc attachment section #####################
resource "aws_ec2_transit_gateway_vpc_attachment" "egress_vpc" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id

  subnet_ids = module.egress_vpc.private_subnet_ids
  vpc_id     = module.egress_vpc.vpc_id

  transit_gateway_default_route_table_association = false

  tags = {
    Name = "egress-vpc-attachment"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "spoke01_vpc" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id

  subnet_ids = module.spoke1_vpc.private_subnet_ids
  vpc_id     = module.spoke1_vpc.vpc_id

  transit_gateway_default_route_table_association = false

  tags = {
    Name = "spoke01-vpc-attachment"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "spoke02_vpc" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id

  subnet_ids = module.spoke2_vpc.private_subnet_ids
  vpc_id     = module.spoke2_vpc.vpc_id

  transit_gateway_default_route_table_association = false

  tags = {
    Name = "spoke02-vpc-attachment"
  }
}

##################################### associate vpc attachments #######################################
resource "aws_ec2_transit_gateway_route_table_association" "egress_vpc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.egress_vpc.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.egress_rt.id
}

resource "aws_ec2_transit_gateway_route_table_association" "vpc_spoke01" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke01_vpc.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_rt.id
}

resource "aws_ec2_transit_gateway_route_table_association" "vpc_spoke02" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke02_vpc.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_rt.id
}

##################################### routing section ################################################
resource "aws_ec2_transit_gateway_route" "egress_vpc" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.egress_vpc.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_rt.id
}

resource "aws_ec2_transit_gateway_route" "blackhole" {
  for_each = toset(var.blackhole_cidrs)

  destination_cidr_block         = each.value
  blackhole                      = true
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_rt.id
}

resource "aws_ec2_transit_gateway_route" "vpc_spoke01" {
  destination_cidr_block         = var.spoke01_cidr_block
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke01_vpc.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.egress_rt.id
}

resource "aws_ec2_transit_gateway_route" "vpc_spoke02" {
  destination_cidr_block         = var.spoke02_cidr_block
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke02_vpc.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.egress_rt.id
}
