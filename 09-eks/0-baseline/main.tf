resource "aws_eks_cluster" "this" {
  name = var.cluster_name

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.cluster_version

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

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
    aws_iam_role_policy_attachment.amzn_eks_cluster,
    aws_iam_role_policy_attachment.amzn_eks_compute,
    aws_iam_role_policy_attachment.amzn_eks_block_storage,
    aws_iam_role_policy_attachment.amzn_eks_networking
  ]

  tags = {
    Name = var.cluster_name
  }
}

resource "aws_launch_template" "cluster_al2023" {
  for_each = var.node_groups

  name = "${var.cluster_name}-${each.key}-lt"

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

  dynamic "tag_specifications" {
    for_each = local.tag_resource_types
    content {
      resource_type = tag_specifications.value

      tags = {
        Name = "${var.cluster_name}-${each.key}"
      }
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
  }))

  tags = {
    Name = "${var.cluster_name}-${each.key}-lt"
  }
}

resource "aws_eks_node_group" "this" {
  for_each = var.node_groups

  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-${each.key}"
  node_role_arn   = aws_iam_role.eks_node.arn
  subnet_ids      = local.private_subnet_ids

  scaling_config {
    desired_size = each.value.desired_size
    max_size     = each.value.max_size
    min_size     = each.value.min_size
  }

  launch_template {
    id      = aws_launch_template.cluster_al2023[each.key].id
    version = aws_launch_template.cluster_al2023[each.key].latest_version
  }

  update_config {
    max_unavailable = 1
  }

  labels = merge(
    each.value.labels,
    {
      Service = var.application
    }
  )

  instance_types = each.value.instance_types
  capacity_type  = each.value.capacity_type

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  depends_on = [
    aws_iam_role_policy_attachment.amzn_eks_worker_node,
    aws_iam_role_policy_attachment.amzn_eks_cni,
    aws_iam_role_policy_attachment.amzn_ec2_container_registry_pull_only,
  ]

  tags = {
    Name = "${var.cluster_name}-${each.key}"
  }
}
