resource "aws_iam_role" "event_publish_role" {
  name = "event-publish-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
  tags = {
    Name = "event-publish-role"
  }
}

resource "aws_iam_role_policy" "test_policy" {
  name = "event-publish-policy"
  role = aws_iam_role.event_publish_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sns:Publish",
        ]
        Effect   = "Allow"
        Resource = "${aws_sns_topic.topic.arn}"
      },
      {
        Action = [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ]
        Effect   = "Allow"
        Resource = "${local.kms_key_arn}"
      }
    ]
  })
}
