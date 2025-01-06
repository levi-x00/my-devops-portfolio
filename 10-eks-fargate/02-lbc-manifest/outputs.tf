output "lbc_iam_policy" {
  value = data.http.lbc_iam_policy.response_body
}

output "lbc_iam_role_arn" {
  value = aws_iam_role.lbc_iam_role.arn
}

output "lbc_helm_metadata" {
  value = helm_release.loadbalancer_controller.metadata
}
