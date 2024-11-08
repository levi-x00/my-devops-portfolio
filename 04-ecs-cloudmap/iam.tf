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

resource "aws_iam_role_policy" "event_publish_policy" {
  name   = "event-publish-role-policy"
  role   = aws_iam_role.event_publish_role.id
  policy = data.aws_iam_policy_document.sns_inline_policy.json
}

data "aws_iam_policy_document" "sns_inline_policy" {
  statement {
    sid = "PublishToSNSPolicy"
    actions = [
      "sns:Publish"
    ]
    resources = [aws_sns_topic.topic.arn]
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
}
