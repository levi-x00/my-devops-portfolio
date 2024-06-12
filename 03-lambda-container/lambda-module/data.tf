data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com"
      ]
    }
  }
}

data "external" "folder_hash" {
  program = ["bash", "${path.module}/check-hash.sh", var.source_dir]
}

data "aws_caller_identity" "current" {}
