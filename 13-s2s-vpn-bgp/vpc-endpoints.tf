resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = module.cloud_vpc.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = module.cloud_vpc.private_subnet_ids
  security_group_ids  = [aws_security_group.cloud_sg.id]
  private_dns_enabled = true

  tags = {
    Name = "ssm-endpoint"
  }
}

resource "aws_vpc_endpoint" "ssm_messages" {
  vpc_id              = module.cloud_vpc.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = module.cloud_vpc.private_subnet_ids
  security_group_ids  = [aws_security_group.cloud_sg.id]
  private_dns_enabled = true

  tags = {
    Name = "ssm-messages-endpoint"
  }
}

resource "aws_vpc_endpoint" "ec2_messages" {
  vpc_id              = module.cloud_vpc.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.ec2messages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = module.cloud_vpc.private_subnet_ids
  security_group_ids  = [aws_security_group.cloud_sg.id]
  private_dns_enabled = true

  tags = {
    Name = "ec2-messages-endpoint"
  }
}
