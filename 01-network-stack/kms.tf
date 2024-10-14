resource "aws_kms_key" "kms" {
  description             = "KMS key for devops"
  deletion_window_in_days = 7

  tags = {
    Name = "${var.project_name}-kms"
  }
}

resource "aws_kms_alias" "kms" {
  name          = "alias/${var.project_name}-kms"
  target_key_id = aws_kms_key.kms.key_id
}

data "aws_iam_policy_document" "kms_policy" {
  statement {
    sid = "Enable IAM User Permissions"

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${local.account_id}:root"
      ]
    }

    actions = ["kms:*"]

    resources = ["*"]
  }

  statement {
    sid = "Allow attachment of persistent resources"

    principals {
      type = "Service"
      identifiers = [
        "logs.amazonaws.com",
        "ec2.amazonaws.com",
        "s3.amazonaws.com"
      ]
    }

    actions = [
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant"
    ]

    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }

    resources = ["*"]
  }

  statement {
    sid = "Allow attachment of persistent resources"

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${local.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
      ]
    }

    actions = [
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant"
    ]

    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }

    resources = ["*"]
  }

  statement {
    sid = "Allow attachment of persistent resources"

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${local.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
      ]
    }

    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]

    resources = ["*"]
  }

  statement {
    sid = "Allow services to use KMS"

    principals {
      type = "Service"
      identifiers = [
        "logs.amazonaws.com",
        "codecommit.amazonaws.com",
        "codebuild.amazonaws.com",
        "codepipeline.amazonaws.com",
        "codecommit.amazonaws.com",
        "codedeploy.amazonaws.com",
        "events.amazonaws.com",
        "ecs.amazonaws.com",
        "ec2.amazonaws.com",
        "eks.amazonaws.com",
        "s3.amazonaws.com",
        "ssm.amazonaws.com",
        "lambda.amazonaws.com"
      ]
    }

    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]

    resources = ["*"]
  }
}

resource "aws_kms_key_policy" "kms" {
  key_id = aws_kms_key.kms.id
  policy = data.aws_iam_policy_document.kms_policy.json
}
