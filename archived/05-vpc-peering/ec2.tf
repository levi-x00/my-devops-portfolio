module "ec2_instance01" {
  depends_on = [aws_vpc_endpoint.eps_01]
  version    = "5.6.1"
  source     = "terraform-aws-modules/ec2-instance/aws"

  name = "instance-01"
  ami  = data.aws_ami.amzlinux2.id

  instance_type = var.instance_type
  subnet_id     = aws_subnet.subnets_vpc01[0].id
  iam_role_name = aws_iam_role.ec2_role.name

  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  vpc_security_group_ids = [aws_security_group.ec2_sg01.id]

  tags = {
    Name = "instance-01"
  }
}

module "ec2_instance02" {
  depends_on = [aws_vpc_endpoint.eps_02]
  version    = "5.6.1"
  source     = "terraform-aws-modules/ec2-instance/aws"

  name = "instance-02"
  ami  = data.aws_ami.amzlinux2.id

  instance_type = var.instance_type
  subnet_id     = aws_subnet.subnets_vpc02[0].id

  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  vpc_security_group_ids = [aws_security_group.ec2_sg02.id]

  tags = {
    Name = "instance-02"
  }
}
