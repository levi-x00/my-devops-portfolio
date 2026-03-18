####################################################################################
# IAM Role for CodePipeline CI/CD to access EKS cluster
####################################################################################
resource "aws_iam_role" "codepipeline" {
  name        = "${var.cluster_name}-codepipeline-role"
  description = "Allows CodePipeline to deploy to the EKS cluster."

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

data "aws_iam_policy_document" "codepipeline_eks_policy" {
  statement {
    sid    = "AllowEKSAccess"
    effect = "Allow"
    actions = [
      "eks:DescribeCluster",
      "eks:ListClusters"
    ]
    resources = [module.eks.cluster_arn]
  }
}

resource "aws_iam_role_policy" "codepipeline_eks" {
  name   = "eks-access-inline-policy"
  role   = aws_iam_role.codepipeline.name
  policy = data.aws_iam_policy_document.codepipeline_eks_policy.json
}

resource "aws_iam_role_policy_attachment" "codepipeline" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AWSCodeBuildDeveloperAccess",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser",
  ])
  policy_arn = each.value
  role       = aws_iam_role.codepipeline.name
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
  for_each = toset([
    "arn:aws:iam::aws:policy/SecretsManagerReadWrite",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
  ])
  policy_arn = each.value
  role       = aws_iam_role.backend.name
}

resource "aws_eks_pod_identity_association" "backend" {
  cluster_name    = module.eks.cluster_id
  namespace       = "backend"
  service_account = "backend"
  role_arn        = aws_iam_role.backend.arn
}
