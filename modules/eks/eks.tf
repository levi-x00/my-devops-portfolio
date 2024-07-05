resource "aws_eks_cluster" "cluster" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = aws_iam_role.eks-cluster-role.arn

  vpc_config {
    endpoint_private_access = false
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]

    subnet_ids = data.terraform_remote_state.network.outputs.private_subnet_ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.vpc-resource-controller,
    aws_iam_role_policy_attachment.pod-exec-role,
    aws_iam_role_policy_attachment.eks-cluster-policy
  ]

  tags = {
    Name = var.cluster_name
  }
}
