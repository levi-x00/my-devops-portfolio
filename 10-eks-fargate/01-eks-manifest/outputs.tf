output "aws_iam_openid_connect_provider_arn" {
  value = aws_iam_openid_connect_provider.eks.arn
}

output "aws_iam_openid_connect_provider_extract_from_arn" {
  value = local.aws_iam_oidc_connect_provider_extract_from_arn
}

output "cluster_endpoint" {
  value = aws_eks_cluster.cluster.endpoint
}

output "cluster_ca" {
  value     = aws_eks_cluster.cluster.certificate_authority[0].data
  sensitive = true
}

output "cluster_security_group_id" {
  value = aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id
}

output "cluster_id" {
  value = aws_eks_cluster.cluster.id
}
