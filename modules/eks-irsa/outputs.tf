output "role_arn" {
  description = "ARN of the IAM role"
  value       = aws_iam_role.this.arn
}

output "role_name" {
  description = "Name of the IAM role"
  value       = aws_iam_role.this.name
}

output "custom_policy_arn" {
  description = "ARN of the custom IAM policy (if created)"
  value       = var.custom_policy_json != null ? aws_iam_policy.custom[0].arn : null
}

output "pod_identity_association_id" {
  description = "ID of the pod identity association"
  value       = aws_eks_pod_identity_association.this.id
}
