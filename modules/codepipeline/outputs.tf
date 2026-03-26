output "arn" {
  description = "The ARN of the CodePipeline"
  value       = aws_codepipeline.this.arn
}

output "id" {
  description = "The ID of the CodePipeline"
  value       = aws_codepipeline.this.id
}

output "role_arn" {
  description = "The IAM role ARN used by the CodePipeline"
  value       = var.iam_role_arn != null ? var.iam_role_arn : aws_iam_role.this[0].arn
}
