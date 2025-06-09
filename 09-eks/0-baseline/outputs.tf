# output "autoscaling_group_name" {
#   value = aws_eks_node_group.this.resources[0].autoscaling_groups[0].name
# }

output "cluster_id" {
  value = aws_eks_cluster.this.id
}

output "cluster_vpc_id" {
  value = local.vpc_id
}

output "cluster_arn" {
  value = aws_eks_cluster.this.arn
}

output "cluster_certificate_authority_data" {
  value     = aws_eks_cluster.this.certificate_authority[0].data
  sensitive = true
}

output "cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "cluster_version" {
  value = aws_eks_cluster.this.version
}

output "cluster_iam_role_name" {
  value = aws_iam_role.eks_cluster.name
}

output "cluster_iam_role_arn" {
  value = aws_iam_role.eks_cluster.arn
}

output "cluster_oidc_issuer_url" {
  value = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

output "cluster_primary_security_group_id" {
  value = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "openid_connect_provider_cluster_arn" {
  value = aws_iam_openid_connect_provider.cluster.arn
}

output "openid_connect_provider_cluster_url" {
  value = aws_iam_openid_connect_provider.cluster.url
}
