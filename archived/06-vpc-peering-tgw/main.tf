resource "aws_instance" "instance01" {
  instance_type = var.instance_type
  subnet_id     = module.vpc1.private_subnet_ids[0]

  ami = var.ami_id

  iam_instance_profile   = aws_iam_instance_profile.ec2_role.name
  vpc_security_group_ids = [aws_security_group.vpc1_ec2_sg.id]

  root_block_device {
    volume_size = var.volume_size
  }

  tags = {
    Name = "instance-01"
  }
}

resource "aws_instance" "instance02" {
  instance_type = var.instance_type
  subnet_id     = module.vpc2.private_subnet_ids[0]

  ami = var.ami_id

  iam_instance_profile   = aws_iam_instance_profile.ec2_role.name
  vpc_security_group_ids = [aws_security_group.vpc2_ec2_sg.id]

  root_block_device {
    volume_size = var.volume_size
  }

  tags = {
    Name = "instance-02"
  }
}
