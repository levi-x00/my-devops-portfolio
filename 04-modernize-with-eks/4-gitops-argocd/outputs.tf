output "argocd_namespace" {
  description = "Namespace where ArgoCD is installed"
  value       = kubernetes_namespace.argocd.metadata[0].name
}

output "argocd_repo_server_role_arn" {
  description = "IAM role ARN for ArgoCD repo-server Pod Identity"
  value       = aws_iam_role.argocd_repo_server.arn
}

output "argocd_image_updater_role_arn" {
  description = "IAM role ARN for ArgoCD Image Updater Pod Identity"
  value       = aws_iam_role.argocd_image_updater.arn
}

output "argocd_codecommit_ssh_key_id" {
  description = "SSH key ID for ArgoCD IAM user (used in CodeCommit SSH URL)"
  value       = aws_iam_user_ssh_key.argocd_codecommit.ssh_public_key_id
}
