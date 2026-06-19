
data "aws_iam_policy_document" "codepipeline_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "codepipeline_policy" {
  statement {
    sid     = "AllowS3Artifacts"
    actions = ["s3:GetObject", "s3:PutObject", "s3:GetBucketVersioning", "s3:GetObjectVersion", "s3:ListBucket"]
    resources = [
      "arn:aws:s3:::${module.artifacts_bucket.bucket_name}",
      "arn:aws:s3:::${module.artifacts_bucket.bucket_name}/*"
    ]
  }

  statement {
    sid     = "AllowCodeBuild"
    actions = ["codebuild:BatchGetBuilds", "codebuild:StartBuild"]
    resources = [
      aws_codebuild_project.backend.arn,
      aws_codebuild_project.frontend.arn
    ]
  }

  statement {
    sid = "AllowCodeCommit"
    actions = [
      "codecommit:GetBranch",
      "codecommit:GetCommit",
      "codecommit:GetRepository",
      "codecommit:GetUploadArchiveStatus",
      "codecommit:UploadArchive",
      "codecommit:CancelUploadArchive"
    ]
    resources = [
      "arn:aws:codecommit:${local.region}:${local.account_id}:${var.backend_repository_name}",
      "arn:aws:codecommit:${local.region}:${local.account_id}:${var.frontend_repository_name}"
    ]
  }

  statement {
    sid     = "AllowKMS"
    actions = ["kms:Encrypt*", "kms:Decrypt*", "kms:ReEncrypt*", "kms:GenerateDataKey*", "kms:Describe*"]
    resources = [local.kms_key_arn]
  }
}

resource "aws_iam_role" "codepipeline" {
  name               = "${var.cluster_name}-cicd-pipeline-role"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_role.json
}

resource "aws_iam_role_policy" "codepipeline" {
  name   = "codepipeline-inline-policy"
  role   = aws_iam_role.codepipeline.name
  policy = data.aws_iam_policy_document.codepipeline_policy.json
}
