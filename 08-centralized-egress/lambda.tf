####################### additional IAM policy ########################
data "aws_iam_policy_document" "inline_policy" {
  statement {
    sid = "AllowS3"
    actions = [
      "s3:GetObject"
    ]
    resources = ["*"]
  }
}

######################## lambda sg section ############################
resource "aws_security_group" "app1_sg" {
  name   = "app1-sg"
  vpc_id = module.spoke1_vpc.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app1-sg"
  }
}

resource "aws_security_group" "app2_sg" {
  name   = "app2-sg"
  vpc_id = module.spoke2_vpc.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app2-sg"
  }
}


######################## lambda section ############################
module "app1" {
  source      = "../modules/lambda"
  lambda_name = "app1"

  runtime     = "python3.9"
  timeout     = 20
  memory_size = 256
  handler     = "lambda_function.lambda_handler"

  source_dir = "${path.module}/src"
  output_dir = "${path.module}/archived-app1"

  security_group_ids = [aws_security_group.app1_sg.id]
  subnet_ids         = module.spoke1_vpc.private_subnet_ids

  lambda_inline_policy = data.aws_iam_policy_document.inline_policy.json

  tags = {
    Name = "app1"
  }
}

module "app2" {
  source      = "../modules/lambda"
  lambda_name = "app2"

  runtime     = "python3.9"
  timeout     = 20
  memory_size = 256
  handler     = "lambda_function.lambda_handler"

  source_dir = "${path.module}/src"
  output_dir = "${path.module}/archived-app2"

  security_group_ids = [aws_security_group.app2_sg.id]
  subnet_ids         = module.spoke2_vpc.private_subnet_ids

  lambda_inline_policy = data.aws_iam_policy_document.inline_policy.json

  tags = {
    Name = "app2"
  }
}
