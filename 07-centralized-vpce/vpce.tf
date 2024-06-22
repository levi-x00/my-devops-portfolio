resource "aws_security_group" "vpce_sg" {
  name   = "vpce-sg"
  vpc_id = module.vpc_vpce.vpc_id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = [
      var.vpc_vpce_cidr,
      var.vpc_spoke1_cidr,
      var.vpc_spoke2_cidr
    ]
  }

  egress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = [
      var.vpc_vpce_cidr,
      var.vpc_spoke1_cidr,
      var.vpc_spoke2_cidr
    ]
  }

  tags = {
    Name = "vpce-sg"
  }
}

resource "aws_security_group" "spoke1_ec2_sg" {
  name   = "spoke1-ec2-sg"
  vpc_id = module.vpc_spoke1.vpc_id

  # ingress {
  #   protocol  = -1
  #   self      = true
  #   from_port = 0
  #   to_port   = 0
  # }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = [
      var.vpc_vpce_cidr,
      var.vpc_spoke1_cidr,
    ]
  }

  egress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = [
      var.vpc_vpce_cidr,
      var.vpc_spoke1_cidr,
    ]
  }

  tags = {
    Name = "spoke1-ec2-sg"
  }
}

resource "aws_security_group" "spoke2_ec2_sg" {
  name   = "spoke2-ec2-sg"
  vpc_id = module.vpc_spoke2.vpc_id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = [
      var.vpc_vpce_cidr,
      var.vpc_spoke1_cidr,
    ]
  }

  egress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = [
      var.vpc_vpce_cidr,
      var.vpc_spoke1_cidr,
    ]
  }

  tags = {
    Name = "spoke2-ec2-sg"
  }
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = module.vpc_vpce.vpc_id
  service_name      = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type = "Interface"

  subnet_ids = module.vpc_vpce.private_subnet_ids

  security_group_ids = [
    aws_security_group.vpce_sg.id,
  ]

  private_dns_enabled = false

  tags = {
    Name = "ssm-vpce"
  }
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id            = module.vpc_vpce.vpc_id
  service_name      = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type = "Interface"

  subnet_ids = module.vpc_vpce.private_subnet_ids

  security_group_ids = [
    aws_security_group.vpce_sg.id,
  ]

  private_dns_enabled = false

  tags = {
    Name = "ssmmessages-vpce"
  }
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id            = module.vpc_vpce.vpc_id
  service_name      = "com.amazonaws.${var.region}.ec2messages"
  vpc_endpoint_type = "Interface"

  subnet_ids = module.vpc_vpce.private_subnet_ids

  security_group_ids = [
    aws_security_group.vpce_sg.id,
  ]

  private_dns_enabled = false

  tags = {
    Name = "ec2messages-vpce"
  }
}
