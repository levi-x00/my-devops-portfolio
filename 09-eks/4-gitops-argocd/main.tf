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

resource "aws_codecommit_repository" "gitops" {
  repository_name = var.gitops_repository_name
  description     = "GitOps repository for ArgoCD manifests"

  tags = {
    Name = var.gitops_repository_name
  }
}

resource "null_resource" "push_gitops" {
  depends_on = [aws_codecommit_repository.gitops]

  triggers = {
    repo_url = aws_codecommit_repository.gitops.clone_url_http
  }

  provisioner "local-exec" {
    command = <<-EOT
      export AWS_PROFILE=${var.aws_profile}
      cd ${abspath(path.module)}/k8s
      git init -b main
      git config credential.helper '!aws codecommit credential-helper $@'
      git config credential.UseHttpPath true
      git config user.email "${var.git_user_email}"
      git config user.name "${var.git_user_name}"
      git remote remove origin 2>/dev/null || true
      git remote add origin ${aws_codecommit_repository.gitops.clone_url_http}
      git add .
      git commit -m "Initial commit" 2>/dev/null || true
      git push origin main
    EOT
  }
}
