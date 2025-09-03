resource "aws_default_network_acl" "public_nacl" {
  default_network_acl_id = aws_vpc.main.default_network_acl_id

  subnet_ids = [
    aws_subnet.public-1a.id,
    aws_subnet.public-1b.id,
    aws_subnet.private-1a.id,
    aws_subnet.private-1b.id,
    aws_subnet.db-1a.id,
    aws_subnet.db-1b.id
  ]

  ingress {
    rule_no    = "100"
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    rule_no    = "100"
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "${var.project_name}-default-nacl"
  }
}

resource "aws_network_acl" "public_nacl" {
  vpc_id = aws_vpc.main.id

  subnet_ids = [
    # aws_subnet.public-1a.id,
    # aws_subnet.public-1b.id,
    # aws_subnet.private-1a.id,
    # aws_subnet.private-1b.id,
    # aws_subnet.db-1a.id,
    # aws_subnet.db-1b.id
  ]

  dynamic "ingress" {
    for_each = local.public_nacl_rules.ingress
    content {
      rule_no    = ingress.value.rule_no
      protocol   = ingress.value.protocol
      action     = ingress.value.action
      cidr_block = ingress.value.cidr_block
      from_port  = ingress.value.from_port
      to_port    = ingress.value.to_port
    }
  }

  dynamic "egress" {
    for_each = local.public_nacl_rules.ingress
    content {
      rule_no    = egress.value.rule_no
      protocol   = egress.value.protocol
      action     = egress.value.action
      cidr_block = "0.0.0.0/0"
      from_port  = egress.value.from_port
      to_port    = egress.value.to_port
    }
  }

  tags = {
    Name = "${var.project_name}-public-nacl"
  }
}

resource "aws_network_acl" "private_nacl" {
  vpc_id = aws_vpc.main.id

  subnet_ids = []

  dynamic "ingress" {
    for_each = local.private_nacl_rules.ingress
    content {
      rule_no    = ingress.value.rule_no
      protocol   = ingress.value.protocol
      action     = ingress.value.action
      cidr_block = ingress.value.cidr_block
      from_port  = ingress.value.from_port
      to_port    = ingress.value.to_port
    }
  }

  dynamic "egress" {
    for_each = local.private_nacl_rules.egress
    content {
      rule_no    = egress.value.rule_no
      protocol   = egress.value.protocol
      action     = egress.value.action
      cidr_block = egress.value.cidr_block
      from_port  = egress.value.from_port
      to_port    = egress.value.to_port
    }
  }

  tags = {
    Name = "${var.project_name}-private-nacl"
  }
}



