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
