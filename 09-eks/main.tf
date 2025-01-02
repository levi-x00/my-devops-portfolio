resource "aws_eks_cluster" "cluster" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids              = local.prv_subnets
    endpoint_private_access = false
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  depends_on = [
    aws_iam_role_policy_attachment.vpc_res_ctrler,
    aws_iam_role_policy_attachment.eks_cluster
  ]
}

resource "aws_eks_node_group" "eks_nodes" {
  depends_on = [
    aws_iam_role_policy_attachment.worker_node,
    aws_iam_role_policy_attachment.eks_cni,
    aws_iam_role_policy_attachment.registry_read_only
  ]

  cluster_name    = aws_eks_cluster.cluster.name
  version         = var.cluster_version
  node_group_name = "${var.cluster_name}-node"
  node_role_arn   = aws_iam_role.eks_nodes_role.arn

  ami_type       = "AL2_x86_64"
  subnet_ids     = local.lb_subnets
  capacity_type  = "ON_DEMAND"
  disk_size      = 32
  instance_types = [var.instance_type]

  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 2
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "general"
  }

  # Allow external changes without Terraform plan difference
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  tags = {
    Name = "${var.cluster_name}-node"
  }
}
