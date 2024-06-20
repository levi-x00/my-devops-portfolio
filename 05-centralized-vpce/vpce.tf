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

resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = module.vpc_vpce.vpc_id
  service_name      = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type = "Interface"

  subnet_ids = module.vpc_vpce.private_subnet_ids

  security_group_ids = [
    aws_security_group.vpce_sg.id,
  ]

  private_dns_enabled = true

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

  private_dns_enabled = true

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

  private_dns_enabled = true

  tags = {
    Name = "ec2messages-vpce"
  }
}
