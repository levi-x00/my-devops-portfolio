output "account_id" {
  value = module.eks.account_id
}

output "cluster_id" {
  value = module.eks.cluster_id
}

output "cluster_vpc_id" {
  value = local.vpc_id
}

output "cluster_arn" {
  value = module.eks.cluster_arn
}

output "cluster_certificate_authority_data" {
  value     = module.eks.cluster_certificate_authority_data
  sensitive = true
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_version" {
  value = module.eks.cluster_version
}

output "cluster_iam_role_name" {
  value = module.eks.cluster_iam_role_name
}

output "cluster_iam_role_arn" {
  value = module.eks.cluster_iam_role_arn
}

output "cluster_oidc_issuer_url" {
  value = module.eks.cluster_oidc_issuer_url
}

output "cluster_primary_security_group_id" {
  value = module.eks.cluster_primary_security_group_id
}

output "openid_connect_provider_cluster_arn" {
  value = module.eks.openid_connect_provider_arn
}

output "openid_connect_provider_cluster_url" {
  value = module.eks.openid_connect_provider_url
}

output "codebuild_role_arn" {
  value = aws_iam_role.codebuild.arn
}

output "db_secret_arn" {
  value = aws_secretsmanager_secret.db.arn
}
