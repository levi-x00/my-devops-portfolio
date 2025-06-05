resource "aws_eks_cluster" "this" {
  name = var.cluster_name

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
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
    subnet_ids              = local.private_subnet_ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSComputePolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSBlockStoragePolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSNetworkingPolicy
  ]

  tags = {
    Name = var.cluster_name
  }
}

resource "aws_launch_template" "cluster_al2023" {
  name = "${var.cluster_name}-node-group-lt"

  image_id               = data.aws_ssm_parameter.eks_al2023.value
  update_default_version = true

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      delete_on_termination = true
      encrypted             = true
      kms_key_id            = local.kms_key_arn
      volume_size           = var.volume_size
      volume_type           = var.volume_type
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.cluster_name}-worker-node"
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    instance_metadata_tags      = "enabled"
    http_put_response_hop_limit = 2 # required by aws-load-balancer controller
  }

  user_data = base64encode(templatefile("userdata.tpl", {
    CLUSTER_NAME         = aws_eks_cluster.this.name,
    B64_CLUSTER_CA       = aws_eks_cluster.this.certificate_authority[0].data,
    API_SERVER_URL       = aws_eks_cluster.this.endpoint,
    CLUSTER_SERVICE_CIDR = var.eks_cluster_cidr
    CLUSTER_DNS_IP       = var.cluster_dns_ip
    IMAGE_ID             = data.aws_ssm_parameter.eks_al2023.value
    NODE_GROUP_NAME      = "${var.cluster_name}-node-group"
  }))

  tags = {
    Name = "${var.cluster_name}-node-group-lt"
  }
}


resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-ng"
  node_role_arn   = aws_iam_role.eks_node.arn
  subnet_ids      = local.private_subnet_ids

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  launch_template {
    id      = aws_launch_template.cluster_al2023.id
    version = aws_launch_template.cluster_al2023.latest_version
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    Service = "myapp"
    Type    = "ON_DEMAND"
  }

  instance_types = ["t3.micro", "t3.small"]

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodeMinimalPolicy,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryPullOnly,
  ]

  tags = {
    Name = "${var.cluster_name}-node-group"
  }
}
