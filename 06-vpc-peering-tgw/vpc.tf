###############################################################
# vpc 1
###############################################################
module "vpc1" {
  source = "../modules/vpc"

  vpc_name       = "vpc1"
  vpc_cidr_block = "10.2.0.0/24"

  private_subnet_cidra = "10.2.0.0/25"
  private_subnet_cidrb = "10.2.0.128/25"

  public_subnet_cidra = "10.2.1.0/25"
  public_subnet_cidrb = "10.2.1.128/25"

  enable_nat = true
  create_igw = true

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
    cidr_blocks = ["10.3.0.0/24"]
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
  vpc_cidr_block = "10.3.0.0/24"

  private_subnet_cidra = "10.3.0.0/25"
  private_subnet_cidrb = "10.3.0.128/25"

  public_subnet_cidra = "10.3.1.0/25"
  public_subnet_cidrb = "10.3.1.128/25"

  enable_nat = true
  create_igw = true

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
    cidr_blocks = ["10.2.0.0/24"]
  }

  lifecycle {
    ignore_changes = [
      ingress, egress
    ]
  }

  tags = { Name = "vpc2-ec2-sg" }
}

