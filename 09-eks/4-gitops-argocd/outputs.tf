output "argocd_namespace" {
  description = "Namespace where ArgoCD is installed"
  value       = kubernetes_namespace.argocd.metadata[0].name
}

output "gitops_repo_clone_url" {
  description = "HTTPS clone URL for the GitOps CodeCommit repository"
  value       = aws_codecommit_repository.gitops.clone_url_http
}
