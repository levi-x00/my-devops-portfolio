resource "aws_iam_role" "lambda_role" {
  name = "${var.lambda_name}-role"

  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json

  tags = {
    Name = "${var.lambda_name}-role"
  }
}

resource "aws_iam_role_policy" "lambda_inline_policy" {
  name   = "lambda-inline-policy"
  role   = aws_iam_role.lambda_role.name
  policy = local.inline_policy
}

resource "aws_iam_role_policy_attachment" "basic_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

resource "aws_iam_role_policy_attachment" "EC2ContainerRegistryPowerUser" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
  role       = aws_iam_role.lambda_role.name
}

resource "aws_iam_role_policy_attachment" "vpc_policy" {
  count      = var.security_group_ids == [] ? 0 : 1
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  role       = aws_iam_role.lambda_role.name
}
