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

  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  depends_on = [
    aws_iam_role_policy_attachment.vpc_res_ctrler,
    aws_iam_role_policy_attachment.eks_cluster
  ]
}

resource "aws_launch_template" "eks_ng" {
  name          = "${var.cluster_name}-ng"
  ebs_optimized = true
  instance_type = var.instance_type
  key_name      = var.key_name

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.volume_size
      volume_type           = var.volume_type
      delete_on_termination = true
    }
  }

  capacity_reservation_specification {
    capacity_reservation_preference = "open"
  }

  monitoring {
    enabled = true
  }

  network_interfaces {
    associate_public_ip_address = false
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.cluster_name}-ng"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = "${var.cluster_name}-ng"
    }
  }

  tag_specifications {
    resource_type = "network-interface"
    tags = {
      Name = "${var.cluster_name}-ng"
    }
  }

  tags = {
    Name = "${var.cluster_name}-ng"
  }
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

  ami_type      = "AL2_x86_64"
  subnet_ids    = local.prv_subnets
  capacity_type = "ON_DEMAND"

  launch_template {
    id      = aws_launch_template.eks_ng.id
    version = "$Latest"
  }

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 2
  }

  update_config {
    max_unavailable = 1
  }

  # Allow external changes without Terraform plan difference
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  tags = {
    Name = "${var.cluster_name}-ng"
  }
}
