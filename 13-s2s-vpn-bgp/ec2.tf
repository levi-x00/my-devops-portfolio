#########################################################################
# security groups
#########################################################################
resource "aws_security_group" "onprem_sg" {
  name   = "onprem-sg"
  vpc_id = module.on_prem_vpc.vpc_id

  description = "Security group for ec2 in on-prem vpc"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    cidr_blocks = [
      var.cloud_vpc_cidr_block
    ]
  }

  ingress {
    from_port = -1
    to_port   = -1
    protocol  = "icmp"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "cloud_sg" {
  name   = "cloud-sg"
  vpc_id = module.cloud_vpc.vpc_id

  description = "Security group for ec2 in cloud vpc"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    cidr_blocks = [
      var.onprem_vpc_cidr_block
    ]
  }

  ingress {
    from_port = -1
    to_port   = -1
    protocol  = "icmp"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#########################################################################
# Elastic IP for OnPrem Router
#########################################################################
resource "aws_eip" "onprem_router" {
  domain = "vpc"

  tags = {
    Name = "onprem-router-eip"
  }
}

resource "aws_eip_association" "onprem_router" {
  instance_id   = aws_instance.onprem_router.id
  allocation_id = aws_eip.onprem_router.id
}
resource "aws_instance" "onprem_router" {
  ami = var.router_ami_id

  instance_type = var.instance_type

  subnet_id                   = module.on_prem_vpc.public_subnet_ids[0]
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.name
  vpc_security_group_ids      = [aws_security_group.onprem_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "onprem-router"
  }
}

resource "aws_instance" "onprem_server" {
  ami = var.router_ami_id

  instance_type = var.instance_type

  subnet_id              = module.on_prem_vpc.private_subnet_ids[0]
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  vpc_security_group_ids = [aws_security_group.onprem_sg.id]

  tags = {
    Name = "onprem-server"
  }
}

resource "aws_instance" "cloud_server_a" {
  ami = var.cloud_ami_id

  instance_type = var.instance_type

  subnet_id              = module.cloud_vpc.private_subnet_ids[0]
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  vpc_security_group_ids = [aws_security_group.cloud_sg.id]

  tags = {
    Name = "AWS-EC2-A"
  }

  depends_on = [
    aws_vpc_endpoint.ssm,
    aws_vpc_endpoint.ssm_messages,
    aws_vpc_endpoint.ec2_messages
  ]
}

resource "aws_instance" "cloud_server_b" {
  ami = var.cloud_ami_id

  instance_type = var.instance_type

  subnet_id              = module.cloud_vpc.private_subnet_ids[1]
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  vpc_security_group_ids = [aws_security_group.cloud_sg.id]

  tags = {
    Name = "AWS-EC2-B"
  }

  depends_on = [
    aws_vpc_endpoint.ssm,
    aws_vpc_endpoint.ssm_messages,
    aws_vpc_endpoint.ec2_messages
  ]
}
