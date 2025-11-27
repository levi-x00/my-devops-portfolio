# kube-system namespace
resource "aws_eks_fargate_profile" "fargate_profile_kube_system" {
  cluster_name = aws_eks_cluster.cluster.id
  subnet_ids   = local.private_subnet_ids

  fargate_profile_name   = "${var.cluster_name}-fp-kube-system"
  pod_execution_role_arn = aws_iam_role.fargate_profile_role.arn

  selector {
    namespace = "kube-system"
  }
}

# By default, CoreDNS is configured to run on Amazon EC2 infrastructure on Amazon EKS clusters
resource "aws_eks_fargate_profile" "fargate_profile_coredns" {
  cluster_name = aws_eks_cluster.cluster.id
  subnet_ids   = local.private_subnet_ids

  fargate_profile_name   = "${var.cluster_name}-fp-coredns"
  pod_execution_role_arn = aws_iam_role.fargate_profile_role.arn

  selector {
    namespace = "kube-system"
    labels = {
      "k8s-app" = "kube-dns"
    }
  }
}

# kube-system namespace
resource "aws_eks_fargate_profile" "fargate_profile_default" {
  cluster_name = aws_eks_cluster.cluster.id
  subnet_ids   = local.private_subnet_ids

  fargate_profile_name   = "${var.cluster_name}-fp-default"
  pod_execution_role_arn = aws_iam_role.fargate_profile_role.arn

  selector {
    namespace = "default"
  }
}
