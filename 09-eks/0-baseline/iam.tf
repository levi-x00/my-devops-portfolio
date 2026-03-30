####################################################################################
# IAM Role for CodeBuild CI/CD to access EKS cluster
####################################################################################
resource "aws_iam_role" "codebuild" {
  name        = "${var.cluster_name}-codebuild-role"
  description = "Allows CodeBuild to deploy to the EKS cluster."

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = ["sts:AssumeRole", "sts:TagSession"]
        Effect    = "Allow"
        Principal = { Service = "codebuild.amazonaws.com" }
      }
    ]
  })
}

data "aws_iam_policy_document" "codebuild_policy" {
  statement {
    sid = "AllowECR"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage"
    ]
    resources = ["*"]
  }

  statement {
    sid       = "AllowEKS"
    actions   = ["eks:DescribeCluster", "eks:ListClusters"]
    resources = [module.eks.cluster_arn]
  }

  statement {
    sid = "AllowS3Artifacts"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning"
    ]
    resources = ["arn:aws:s3:::*"]
  }

  statement {
    sid       = "AllowCloudWatchLogs"
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
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
}

resource "aws_iam_role_policy" "codebuild" {
  name   = "codebuild-inline-policy"
  role   = aws_iam_role.codebuild.name
  policy = data.aws_iam_policy_document.codebuild_policy.json
}

####################################################################################
# IAM Role and Pod Identity Association for backend Service Account
####################################################################################
data "aws_iam_policy_document" "pod_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole", "sts:TagSession"]
    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "backend" {
  name               = "${var.cluster_name}-backend-role"
  assume_role_policy = data.aws_iam_policy_document.pod_assume_role_policy.json
}

data "aws_iam_policy_document" "kms_inline_policy" {
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

resource "aws_iam_role_policy" "kms_policy" {
  name   = "kms-inline-policy"
  role   = aws_iam_role.backend.name
  policy = data.aws_iam_policy_document.kms_inline_policy.json
}

resource "aws_iam_role_policy_attachment" "backend" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.backend.name
}

resource "aws_eks_pod_identity_association" "backend" {
  cluster_name    = module.eks.cluster_id
  namespace       = "backend"
  service_account = "backend"
  role_arn        = aws_iam_role.backend.arn
}
