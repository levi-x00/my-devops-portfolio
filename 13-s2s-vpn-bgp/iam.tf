#########################################################################
# IAM Role for EC2 Instances
#########################################################################
resource "aws_iam_role" "ec2_role" {
  name = "ec2-ssm-role"

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
    Name = "ec2-ssm-role"
  }
}

resource "aws_iam_role_policy_attachment" "amzn_ec2_role_for_ssm" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
  role       = aws_iam_role.ec2_role.name
}

resource "iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-ssm-role"
  role = aws_iam_role.ec2_role.name
}
