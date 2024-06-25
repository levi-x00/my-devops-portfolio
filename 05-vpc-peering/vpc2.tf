# ==== vpc 02 section ====
resource "aws_vpc" "vpc_02" {
  cidr_block       = var.vpc2_cidr_block
  instance_tenancy = "default"

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "vpc-02"
  }
}

# create subnets from vpc-02
resource "aws_subnet" "subnets_vpc02" {
  count = length(var.subnets_vpc02)

  vpc_id            = aws_vpc.vpc_02.id
  cidr_block        = var.subnets_vpc02[count.index].cidr
  availability_zone = local.azs[count.index % length(local.azs)]
  tags = {
    Name = "private-${var.subnets_vpc02[count.index].name}-02"
  }
}

# create rt from vpc-02
resource "aws_route_table" "private_rt_vpc02" {
  depends_on = [
    aws_vpc_peering_connection.vpc_peering
  ]

  route {
    cidr_block                = var.vpc1_cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
  }

  vpc_id = aws_vpc.vpc_02.id

  tags = {
    Name = "private-${var.environment}-rt-02"
  }
}

# associcate subnet to rt
resource "aws_route_table_association" "association02" {
  count = length(var.subnets_vpc02)

  subnet_id      = aws_subnet.subnets_vpc02[count.index].id
  route_table_id = aws_route_table.private_rt_vpc02.id
}

resource "aws_security_group" "ec2_sg02" {
  name   = "ec2-${var.environment}-sg-02"
  vpc_id = aws_vpc.vpc_02.id

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
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = false
  }

  tags = {
    Name = "ec2-${var.environment}-sg-02"
  }
}

resource "aws_security_group" "ep_sg02" {
  name   = "ep-${var.environment}-sg-02"
  vpc_id = aws_vpc.vpc_02.id

  dynamic "ingress" {
    for_each = local.ep_inbound_ports
    content {
      from_port       = ingress.value
      to_port         = ingress.value
      protocol        = "tcp"
      security_groups = [aws_security_group.ec2_sg02.id]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "ep-${var.environment}-sg-02"
  }
}

resource "aws_vpc_endpoint" "eps_02" {
  for_each          = toset(var.endpoint_services)
  vpc_id            = aws_vpc.vpc_02.id
  service_name      = "com.amazonaws.${var.region}.${each.value}"
  vpc_endpoint_type = "Interface"

  subnet_ids = [for subnet in aws_subnet.subnets_vpc02 : subnet.id]

  security_group_ids = [
    aws_security_group.ep_sg02.id,
  ]

  private_dns_enabled = true

  tags = {
    Name = "ep-${each.value}-02"
  }
}
