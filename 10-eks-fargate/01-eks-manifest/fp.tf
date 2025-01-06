# kube-system namespace
resource "aws_eks_fargate_profile" "fargate_profile_kube_system" {
  cluster_name = aws_eks_cluster.cluster.id
  subnet_ids   = local.prv_subnets

  fargate_profile_name   = "${var.cluster_name}-fp-kube-system"
  pod_execution_role_arn = aws_iam_role.fargate_profile_role.arn

  selector {
    namespace = "kube-system"
  }
}

# kube-system namespace
resource "aws_eks_fargate_profile" "fargate_profile_default" {
  cluster_name = aws_eks_cluster.cluster.id
  subnet_ids   = local.prv_subnets

  fargate_profile_name   = "${var.cluster_name}-fp-default"
  pod_execution_role_arn = aws_iam_role.fargate_profile_role.arn

  selector {
    namespace = "default"
  }
}
