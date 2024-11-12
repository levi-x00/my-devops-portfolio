data "aws_iam_policy_document" "ssm_policy" {
  statement {
    sid = "SSMExecPolicy"
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    resources = ["*"]
  }

  statement {
    sid = "ECSExecCommand"
    actions = [
      "ecs:ExecuteCommand"
    ]
    resources = ["*"]
  }

  statement {
    sid = "AllowKMS"
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    resources = [local.kms_key_arn]
  }

  statement {
    sid = "AllowS3AndLogs"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "s3:*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "task_role" {
  name = "${var.service_name}-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.service_name}-task-role"
  }
}

resource "aws_iam_role_policy" "ssm_policy" {
  name   = "ssm-policy"
  role   = aws_iam_role.task_role.arn
  policy = data.aws_iam_policy_document.ssm_policy.json
}

resource "aws_iam_role_policy_attachment" "AmazonECSTaskExecutionRolePolicy" {
  role       = aws_iam_role.task_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
