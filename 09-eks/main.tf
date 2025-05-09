resource "aws_eks_cluster" "this" {
  name = var.cluster_name

  access_config {
    authentication_mode = "API"
  }

  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.cluster_version

  encryption_config {
    provider {
      key_arn = local.kms_key_arn
    }
    resources = ["secrets"]
  }

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]

    # vpc_id     = local.vpc_id
    subnet_ids = local.prv_subnets

    # cluster_security_group_id = "sg-00c2b32532eefca66"
  }

  # Ensure that IAM Role permissions are created before and deleted
  # after EKS Cluster handling. Otherwise, EKS will not be able to
  # properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSComputePolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSBlockStoragePolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSNetworkingPolicy
  ]
}

resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-ng"
  node_role_arn   = aws_iam_role.eks_node.arn
  subnet_ids      = local.prv_subnets

  version = var.cluster_version

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    Service = "myapp"
  }

  disk_size      = 20
  instance_types = ["t3.micro", "t3.small"]

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodeMinimalPolicy,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryPullOnly,
  ]
}
