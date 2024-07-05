output "cluster_id" {
  description = "The name/id of the EKS cluster."
  value       = aws_eks_cluster.cluster.id
}

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster."
  value       = aws_eks_cluster.cluster.arn
}

output "cluster_certificate_authority_data" {
  description = "Nested attribute containing certificate-authority-data for your cluster. This is the base64 encoded certificate data required to communicate with your cluster."
  value       = aws_eks_cluster.cluster.certificate_authority[0].data
}

output "cluster_endpoint" {
  description = "The endpoint for your EKS Kubernetes API."
  value       = aws_eks_cluster.cluster.endpoint
}

output "cluster_version" {
  description = "The Kubernetes server version for the EKS cluster."
  value       = aws_eks_cluster.cluster.version
}

output "cluster_iam_role_name" {
  description = "IAM role name of the EKS cluster."
  value       = aws_iam_role.eks-cluster-role.name
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster."
  value       = aws_iam_role.eks-cluster-role.arn
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  value       = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

output "cluster_primary_security_group_id" {
  description = "The cluster primary security group ID created by the EKS cluster on 1.14 or later. Referred to as 'Cluster security group' in the EKS console."
  value       = aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id
}

# EKS Node Group Outputs
output "node_group_id" {
  description = "Node Group ID"
  value       = aws_eks_node_group.eks_ng.id
}

output "node_group_arn" {
  description = "Node Group ARN"
  value       = aws_eks_node_group.eks_ng.arn
}

output "node_group_status" {
  description = "Node Group status"
  value       = aws_eks_node_group.eks_ng.status
}

output "node_group_version" {
  description = "Node Group Kubernetes Version"
  value       = aws_eks_node_group.eks_ng.version
}
