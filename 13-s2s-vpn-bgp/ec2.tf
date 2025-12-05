#########################################################################
# security groups
#########################################################################
resource "aws_security_group" "onprem_sg" {
  name   = "spoke1-ec2-sg"
  vpc_id = module.on_prem_vpc.vpc_id

  description = "Security group for ec2 in on-prem vpc"

  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    cidr_blocks = [
      var.cloud_vpc_cidr_block
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "cloud_sg" {
  name   = "spoke2-ec2-sg"
  vpc_id = module.cloud_vpc.vpc_id

  description = "Security group for ec2 in cloud vpc"

  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    cidr_blocks = [
      var.onprem_vpc_cidr_block
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#########################################################################
# EC2 on On-Premises VPC
#########################################################################
resource "aws_instance" "onprem_router" {
  ami = var.ami_id

  instance_type = var.instance_type

  subnet_id            = module.on_prem_vpc.public_subnet_ids[0]
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  security_groups = [
    aws_security_group.onprem_sg.id
  ]

  tags = {
    Name = "onprem-router"
  }
}

resource "aws_instance" "onprem_server" {
  ami = var.ami_id

  instance_type = var.instance_type

  subnet_id            = module.on_prem_vpc.private_subnet_ids[0]
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  security_groups = [
    aws_security_group.onprem_sg.id
  ]

  tags = {
    Name = "onprem-server"
  }
}

resource "aws_instance" "server" {
  ami = var.ami_id

  instance_type = var.instance_type

  subnet_id            = module.cloud_vpc.private_subnet_ids[0]
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  security_groups = [
    aws_security_group.cloud_sg.id
  ]

  tags = {
    Name = "cloud-ec2"
  }
}
