# ==== vpc 01 section ====
resource "aws_vpc" "vpc_01" {
  cidr_block       = "10.0.0.0/24"
  instance_tenancy = "default"

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge({ Name = "vpc-01" }, local.default_tags)
}

# create subnets from vpc-01
resource "aws_subnet" "subnets_vpc01" {
  count = length(var.subnets_vpc01)

  vpc_id            = aws_vpc.vpc_01.id
  cidr_block        = var.subnets_vpc01[count.index].cidr
  availability_zone = local.azs[count.index % length(local.azs)]
  tags = merge({
    Name = "private-${var.subnets_vpc01[count.index].name}-01"
  }, local.default_tags)
}

# create rt from vpc-01
resource "aws_route_table" "private_rt_vpc01" {
  depends_on = [
    aws_vpc_peering_connection.vpc_peering
  ]

  route {
    cidr_block                = "10.1.0.0/24"
    vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
  }

  vpc_id = aws_vpc.vpc_01.id

  tags = merge({
    Name = "private-${var.environment}-rt-01",
  }, local.default_tags)
}

# associcate subnet to rt
resource "aws_route_table_association" "association01" {
  count = length(var.subnets_vpc01)

  subnet_id      = aws_subnet.subnets_vpc01[count.index].id
  route_table_id = aws_route_table.private_rt_vpc01.id
}

resource "aws_security_group" "ec2_sg01" {
  name   = "ec2-${var.environment}-sg-01"
  vpc_id = aws_vpc.vpc_01.id

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

  tags = merge(
    { Name = "ec2-${var.environment}-sg-01" },
    local.default_tags
  )
}

resource "aws_security_group" "ep_sg01" {
  name   = "ep-${var.environment}-sg-01"
  vpc_id = aws_vpc.vpc_01.id

  dynamic "ingress" {
    for_each = local.ep_inbound_ports
    content {
      from_port       = ingress.value
      to_port         = ingress.value
      protocol        = "tcp"
      security_groups = [aws_security_group.ec2_sg01.id]
    }
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

  tags = merge(
    { Name = "ep-${var.environment}-sg-01" },
    local.default_tags
  )
}

resource "aws_vpc_endpoint" "eps_01" {
  for_each          = toset(var.endpoint_services)
  vpc_id            = aws_vpc.vpc_01.id
  service_name      = replace(each.value, "region", var.region)
  vpc_endpoint_type = "Interface"

  subnet_ids = [for subnet in aws_subnet.subnets_vpc01 : subnet.id]

  security_group_ids = [
    aws_security_group.ep_sg01.id,
  ]

  private_dns_enabled = true

  tags = merge({
    Name = "ep-${split(".", each.value)[3]}-01",
  }, local.default_tags)
}

# ==== vpc 02 section ====
resource "aws_vpc" "vpc_02" {
  cidr_block       = "10.1.0.0/24"
  instance_tenancy = "default"

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge({ Name = "vpc-02" }, local.default_tags)
}

# create subnets from vpc-02
resource "aws_subnet" "subnets_vpc02" {
  count = length(var.subnets_vpc02)

  vpc_id            = aws_vpc.vpc_02.id
  cidr_block        = var.subnets_vpc02[count.index].cidr
  availability_zone = local.azs[count.index % length(local.azs)]
  tags = merge({
    Name = "private-${var.subnets_vpc02[count.index].name}-02"
  }, local.default_tags)
}

# create rt from vpc-02
resource "aws_route_table" "private_rt_vpc02" {
  depends_on = [
    aws_vpc_peering_connection.vpc_peering
  ]

  route {
    cidr_block                = "10.0.0.0/24"
    vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
  }

  vpc_id = aws_vpc.vpc_02.id

  tags = merge({
    Name = "private-${var.environment}-rt-02"
  }, local.default_tags)
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

  tags = merge(
    { Name = "ec2-${var.environment}-sg-02" },
    local.default_tags
  )
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

  tags = merge(
    { Name = "ep-${var.environment}-sg-02" },
    local.default_tags
  )
}

resource "aws_vpc_endpoint" "eps_02" {
  for_each          = toset(var.endpoint_services)
  vpc_id            = aws_vpc.vpc_02.id
  service_name      = replace(each.value, "region", var.region)
  vpc_endpoint_type = "Interface"

  subnet_ids = [for subnet in aws_subnet.subnets_vpc02 : subnet.id]

  security_group_ids = [
    aws_security_group.ep_sg02.id,
  ]

  private_dns_enabled = true

  tags = merge({
    Name = "ep-${split(".", each.value)[3]}-02",
  }, local.default_tags)
}

module "ec2_instance01" {
  depends_on = [aws_vpc_endpoint.eps_01]

  source = "terraform-aws-modules/ec2-instance/aws"

  name = "instance-01"
  ami  = data.aws_ami.amzlinux2.id

  instance_type = var.instance_type
  subnet_id     = aws_subnet.subnets_vpc01[0].id
  iam_role_name = aws_iam_role.ec2_role.name

  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  vpc_security_group_ids = [aws_security_group.ec2_sg01.id]

  tags = merge({
    Name = "instance-01"
  }, local.default_tags)
}

module "ec2_instance02" {
  depends_on = [aws_vpc_endpoint.eps_02]

  source = "terraform-aws-modules/ec2-instance/aws"

  name = "instance-02"
  ami  = data.aws_ami.amzlinux2.id

  instance_type = var.instance_type
  subnet_id     = aws_subnet.subnets_vpc02[0].id

  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  vpc_security_group_ids = [aws_security_group.ec2_sg02.id]

  tags = merge({
    Name = "instance-02"
  }, local.default_tags)
}

# peering section
resource "aws_vpc_peering_connection" "vpc_peering" {
  peer_vpc_id = aws_vpc.vpc_01.id
  vpc_id      = aws_vpc.vpc_02.id
  # peer_region = var.region
  auto_accept = true

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags = merge({
    Name = "peering-vpc01-vpc02"
  }, local.default_tags)
}
