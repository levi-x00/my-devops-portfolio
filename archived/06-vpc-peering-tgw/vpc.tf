###############################################################
# vpc 1
###############################################################
module "vpc1" {
  source = "../modules/vpc"

  vpc_name       = "vpc1"
  vpc_cidr_block = "10.0.2.0/24"

  private_subnet_cidra = "10.0.2.0/26"
  private_subnet_cidrb = "10.0.2.64/26"

  public_subnet_cidra = "10.0.2.128/26"
  public_subnet_cidrb = "10.0.2.192/26"

  enable_nat   = true
  create_igw   = true
  multi_az_nat = false

  tags = { Name = "vpc1" }
}

resource "aws_security_group" "vpc1_ec2_sg" {
  name = "vpc1-ec2-sg"

  vpc_id = module.vpc1.vpc_id

  dynamic "ingress" {
    for_each = local.ec2_inbound_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.0.3.0/24"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    ignore_changes = [
      ingress, egress
    ]
  }

  tags = { Name = "vpc1-ec2-sg" }
}

###############################################################
# vpc 2
###############################################################
module "vpc2" {
  source = "../modules/vpc"

  vpc_name       = "vpc2"
  vpc_cidr_block = "10.0.3.0/24"

  private_subnet_cidra = "10.0.3.0/26"
  private_subnet_cidrb = "10.0.3.64/26"

  public_subnet_cidra = "10.0.3.128/26"
  public_subnet_cidrb = "10.0.3.192/26"

  enable_nat   = true
  create_igw   = true
  multi_az_nat = false

  tags = { Name = "vpc2" }
}

resource "aws_security_group" "vpc2_ec2_sg" {
  name = "vpc2-ec2-sg"

  vpc_id = module.vpc2.vpc_id

  dynamic "ingress" {
    for_each = local.ec2_inbound_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.0.2.0/24"]
  }

  lifecycle {
    ignore_changes = [
      ingress, egress
    ]
  }

  tags = { Name = "vpc2-ec2-sg" }
}

###############################################################
# Routes
###############################################################
resource "aws_route" "vpc1_to_vpc2" {
  destination_cidr_block = "10.0.3.0/24"
  route_table_id         = module.vpc1.private1_rtb_id
  transit_gateway_id     = aws_ec2_transit_gateway.my_tgw.id
}

resource "aws_route" "vpc2_to_vpc1" {
  destination_cidr_block = "10.0.2.0/24"
  route_table_id         = module.vpc2.private1_rtb_id
  transit_gateway_id     = aws_ec2_transit_gateway.my_tgw.id
}
