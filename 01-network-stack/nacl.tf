resource "aws_default_network_acl" "def-nacl" {
  default_network_acl_id = aws_vpc.main.default_network_acl_id

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "deny"
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
    aws_subnet.public-1a.id,
    aws_subnet.public-1b.id
  ]

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 101
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 102
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 103
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 53
    to_port    = 53
  }

  ingress {
    protocol   = "udp"
    rule_no    = 104
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 53
    to_port    = 53
  }

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  egress {
    protocol   = "tcp"
    rule_no    = 101
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  egress {
    protocol   = "tcp"
    rule_no    = 102
    action     = "allow"
    cidr_block = "10.0.0.0/23"
    from_port  = 443
    to_port    = 443
  }

  egress {
    protocol   = "tcp"
    rule_no    = 103
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    protocol   = "tcp"
    rule_no    = 104
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 53
    to_port    = 53
  }

  egress {
    protocol   = "udp"
    rule_no    = 105
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 53
    to_port    = 53
  }

  tags = {
    Name = "${var.project_name}-public-nacl"
  }
}

resource "aws_network_acl" "private_nacl" {
  vpc_id = aws_vpc.main.id

  subnet_ids = [
    aws_subnet.private-1a.id,
    aws_subnet.private-1b.id
  ]

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 101
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 102
    action     = "allow"
    cidr_block = var.vpc_cidr_block
    from_port  = 1024
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 103
    action     = "allow"
    cidr_block = var.vpc_cidr_block
    from_port  = 53
    to_port    = 53
  }

  ingress {
    protocol   = "udp"
    rule_no    = 104
    action     = "allow"
    cidr_block = var.vpc_cidr_block
    from_port  = 53
    to_port    = 53
  }

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  egress {
    protocol   = "tcp"
    rule_no    = 101
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  egress {
    protocol   = "tcp"
    rule_no    = 102
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    protocol   = "tcp"
    rule_no    = 103
    action     = "allow"
    cidr_block = "10.0.3.0/24"
    from_port  = 3306
    to_port    = 3306
  }

  egress {
    protocol   = "tcp"
    rule_no    = 104
    action     = "allow"
    cidr_block = "10.0.3.0/24"
    from_port  = 5432
    to_port    = 5432
  }

  egress {
    protocol   = "tcp"
    rule_no    = 105
    action     = "allow"
    cidr_block = var.vpc_cidr_block
    from_port  = 53
    to_port    = 53
  }

  egress {
    protocol   = "udp"
    rule_no    = 106
    action     = "allow"
    cidr_block = var.vpc_cidr_block
    from_port  = 53
    to_port    = 53
  }

  tags = {
    Name = "${var.project_name}-private-nacl"
  }
}

resource "aws_network_acl" "db_nacl" {
  vpc_id = aws_vpc.main.id

  subnet_ids = [
    aws_subnet.db-1a.id,
    aws_subnet.db-1b.id
  ]

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.2.0/24"
    from_port  = 3306
    to_port    = 3306
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 101
    action     = "allow"
    cidr_block = "10.0.2.0/24"
    from_port  = 5432
    to_port    = 5432
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 102
    action     = "allow"
    cidr_block = var.vpc_cidr_block
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.2.0/24"
    from_port  = 1024
    to_port    = 65535
  }

  tags = {
    Name = "${var.project_name}-db-nacl"
  }
}
