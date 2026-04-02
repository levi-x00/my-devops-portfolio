resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  version    = var.argocd_version

  values = [
    templatefile("${path.module}/helm/argocd-values.yaml", {
      region       = local.region
      cluster_name = local.cluster_name
    })
  ]

  depends_on = [kubernetes_namespace.argocd]
}

resource "helm_release" "argo_rollouts" {
  name       = "argo-rollouts"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-rollouts"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  version    = var.argo_rollouts_version

  set = [
    {
      name  = "dashboard.enabled"
      value = "true"
    }
  ]

  depends_on = [helm_release.argocd]
}

####################################################################################
# ArgoCD Image Updater
####################################################################################
resource "null_resource" "argocd_image_updater" {
  depends_on = [helm_release.argocd]

  provisioner "local-exec" {
    command = "kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/stable/config/install.yaml"
  }
}

####################################################################################
# IAM Role for ArgoCD repo-server (CodeCommit SSH access via Pod Identity)
####################################################################################
resource "aws_iam_role" "argocd_repo_server" {
  name = "${local.cluster_name}-argocd-repo-server-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "pods.eks.amazonaws.com" }
      Action    = ["sts:AssumeRole", "sts:TagSession"]
    }]
  })
}

resource "aws_iam_role_policy" "argocd_repo_server" {
  name = "codecommit-gitpull"
  role = aws_iam_role.argocd_repo_server.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["codecommit:GitPull"]
      Resource = [
        "arn:aws:codecommit:${local.region}:${local.account_id}:${var.backend_repository_name}",
        "arn:aws:codecommit:${local.region}:${local.account_id}:${var.frontend_repository_name}"
      ]
    }]
  })
}

resource "aws_eks_pod_identity_association" "argocd_repo_server" {
  cluster_name    = local.cluster_name
  namespace       = "argocd"
  service_account = "argocd-repo-server"
  role_arn        = aws_iam_role.argocd_repo_server.arn
}

####################################################################################
# IAM Role for ArgoCD Image Updater + ECR Token Refresher (ECR access via Pod Identity)
####################################################################################
resource "aws_iam_role" "argocd_image_updater" {
  name = "${local.cluster_name}-argocd-image-updater-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "pods.eks.amazonaws.com" }
      Action    = ["sts:AssumeRole", "sts:TagSession"]
    }]
  })
}

resource "aws_iam_role_policy" "argocd_image_updater" {
  name = "ecr-readonly"
  role = aws_iam_role.argocd_image_updater.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:DescribeImages",
        "ecr:ListImages"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_eks_pod_identity_association" "argocd_image_updater" {
  cluster_name    = local.cluster_name
  namespace       = "argocd"
  service_account = "argocd-image-updater-controller"
  role_arn        = aws_iam_role.argocd_image_updater.arn
}

resource "aws_eks_pod_identity_association" "ecr_token_refresher" {
  cluster_name    = local.cluster_name
  namespace       = "argocd"
  service_account = "ecr-token-refresher"
  role_arn        = aws_iam_role.argocd_image_updater.arn
}

####################################################################################
# IAM User for ArgoCD CodeCommit SSH access
####################################################################################
resource "aws_iam_user" "argocd_codecommit" {
  name = "argocd-codecommit"
}

resource "aws_iam_user_policy_attachment" "argocd_codecommit" {
  user       = aws_iam_user.argocd_codecommit.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeCommitReadOnly"
}

resource "aws_iam_user_ssh_key" "argocd_codecommit" {
  username   = aws_iam_user.argocd_codecommit.name
  encoding   = "SSH"
  public_key = var.argocd_ssh_public_key
}
