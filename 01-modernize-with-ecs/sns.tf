#####################################################################
# SNS topic
#####################################################################
resource "aws_sns_topic" "topic" {
  name              = "${var.cluster_name}-topic"
  kms_master_key_id = local.kms_key_arn

  tags = {
    Name = "${var.cluster_name}-topic"
  }
}

#####################################################################
# SNS topic policy
#####################################################################
resource "aws_sns_topic_policy" "topic_policy" {
  arn    = aws_sns_topic.topic.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

data "aws_iam_policy_document" "sns_topic_policy" {
  policy_id = "__default_policy_ID"

  statement {
    sid    = "AWSEvents_codebuild-events"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
    actions = ["sns:Publish"]
    resources = [
      aws_sns_topic.topic.arn,
    ]
  }

  statement {
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        local.account_id,
      ]
    }

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      aws_sns_topic.topic.arn,
    ]

    sid = "__default_statement_ID"
  }
}
