####################### IAM for EC2 #######################
resource "aws_iam_role" "ec2_role" {
  name = "ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name = "ec2-role"
  }
}

resource "aws_iam_role_policy_attachment" "AmazonSSMFullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
  role       = aws_iam_role.ec2_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonS3FullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.ec2_role.name
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}

###################################################################
data "aws_ami" "amzlinux2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_instance" "from_spoke1" {
  ami = data.aws_ami.amzlinux2.id

  instance_type = "t3.micro"
  subnet_id     = module.vpc_spoke1.private_subnet_ids[0]

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  security_groups = [
    aws_security_group.spoke1_ec2_sg.id
  ]

  tags = {
    Name = "spoke1-ec2"
  }
}

resource "aws_instance" "from_spoke2" {
  ami           = data.aws_ami.amzlinux2.id
  instance_type = "t3.micro"

  subnet_id = module.vpc_spoke2.private_subnet_ids[0]

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  security_groups = [
    aws_security_group.spoke2_ec2_sg.id
  ]

  tags = {
    Name = "spoke1-ec2"
  }
}
