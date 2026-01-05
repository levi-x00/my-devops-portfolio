#########################################################################
# Security Groups
#########################################################################
resource "aws_security_group" "cloud_sg" {
  name        = "cloud-sg"
  description = "cloud AWS SG"
  vpc_id      = module.cloud_vpc.vpc_id

  ingress {
    self        = true
    description = "Allow to Internal AWS"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  ingress {
    description = "Allow SSH IPv4 IN"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow ALL from ONPREM Networks"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["192.168.8.0/21"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cloud-sg"
  }
}

resource "aws_security_group" "onprem_sg" {
  name        = "onprem-sg"
  description = "Default ONPREM SG"
  vpc_id      = module.on_prem_vpc.vpc_id

  ingress {
    self        = true
    description = "Allow to Internal ONPREM"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  ingress {
    description = "Allow All from AWS Environment"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.16.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "onprem-sg"
  }
}

#########################################################################
# AWS VPC EC2 Instances
#########################################################################
resource "aws_instance" "cloud_ec2_a" {
  ami = var.ami_id

  instance_type = var.instance_type
  subnet_id     = module.cloud_vpc.private_subnet_ids[0]

  iam_instance_profile = aws_iam_instance_profile.ec2_ssm.name

  vpc_security_group_ids = [
    aws_security_group.cloud_sg.id
  ]

  tags = {
    Name = "aws-ec2-A"
  }
}

#########################################################################
# On-Prem Router 1 Network Interfaces
#########################################################################
resource "aws_network_interface" "router1_public" {
  subnet_id         = module.on_prem_vpc.public_subnet_ids[0]
  security_groups   = [aws_security_group.onprem_sg.id]
  source_dest_check = false

  tags = {
    Name = "onprem-router1-public"
  }
}

resource "aws_network_interface" "router1_private" {
  subnet_id         = module.on_prem_vpc.private_subnet_ids[0]
  security_groups   = [aws_security_group.onprem_sg.id]
  source_dest_check = false

  tags = {
    Name = "onprem-router1-private"
  }
}

#########################################################################
# On-Prem Router 2 Network Interfaces
#########################################################################
resource "aws_network_interface" "router2_public" {
  subnet_id         = module.on_prem_vpc.public_subnet_ids[0]
  security_groups   = [aws_security_group.onprem_sg.id]
  source_dest_check = false

  tags = {
    Name = "onprem-router2-public"
  }
}

resource "aws_network_interface" "router2_private" {
  subnet_id         = module.on_prem_vpc.private_subnet_ids[1]
  security_groups   = [aws_security_group.onprem_sg.id]
  source_dest_check = false

  tags = {
    Name = "onprem-router2-private"
  }
}

#########################################################################
# Elastic IPs for Routers
#########################################################################
resource "aws_eip" "router1" {
  domain = "vpc"

  tags = {
    Name = "onprem-router1-eip"
  }

  depends_on = [module.on_prem_vpc]
}

resource "aws_eip_association" "router1" {
  allocation_id        = aws_eip.router1.id
  network_interface_id = aws_network_interface.router1_public.id
}

resource "aws_eip" "router2" {
  domain = "vpc"

  tags = {
    Name = "onprem-router2-eip"
  }

  depends_on = [module.on_prem_vpc]
}

resource "aws_eip_association" "router2" {
  allocation_id        = aws_eip.router2.id
  network_interface_id = aws_network_interface.router2_public.id
}

#########################################################################
# On-Prem Router Instances
#########################################################################
resource "aws_instance" "onprem_router1" {
  ami           = var.router_ami_id
  instance_type = var.router_instance_type

  iam_instance_profile = aws_iam_instance_profile.ec2_ssm.name

  user_data = templatefile("${path.module}/user-data-router1.sh", {
    branch       = var.branch
    project_name = var.project_name
  })

  network_interface {
    network_interface_id  = aws_network_interface.router1_public.id
    device_index          = 0
    delete_on_termination = false
  }

  network_interface {
    network_interface_id  = aws_network_interface.router1_private.id
    device_index          = 1
    delete_on_termination = false
  }

  tags = {
    Name = "onprem-router1"
  }

  lifecycle {
    ignore_changes = [network_interface]
  }
}

resource "aws_instance" "onprem_router2" {
  ami           = var.router_ami_id
  instance_type = var.router_instance_type

  iam_instance_profile = aws_iam_instance_profile.ec2_ssm.name

  user_data = templatefile("${path.module}/user-data-router2.sh", {
    branch       = var.branch
    project_name = var.project_name
  })

  network_interface {
    network_interface_id  = aws_network_interface.router2_public.id
    device_index          = 0
    delete_on_termination = false
  }

  network_interface {
    network_interface_id  = aws_network_interface.router2_private.id
    device_index          = 1
    delete_on_termination = false
  }

  tags = {
    Name = "onprem-router2"
  }

  lifecycle {
    ignore_changes = [network_interface]
  }
}

#########################################################################
# On-Prem Server Instances
#########################################################################
resource "aws_instance" "onprem_server1" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = module.on_prem_vpc.private_subnet_ids[0]

  iam_instance_profile = aws_iam_instance_profile.ec2_ssm.name

  vpc_security_group_ids = [
    aws_security_group.onprem_sg.id
  ]

  tags = {
    Name = "onprem-server1"
  }
}

resource "aws_instance" "onprem_server2" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = module.on_prem_vpc.private_subnet_ids[1]

  iam_instance_profile = aws_iam_instance_profile.ec2_ssm.name

  vpc_security_group_ids = [
    aws_security_group.onprem_sg.id
  ]

  tags = {
    Name = "onprem-server2"
  }
}
