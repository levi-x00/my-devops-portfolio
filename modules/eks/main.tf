resource "aws_ec2_tag" "private_subnet" {
  for_each    = local.private_subnet_tags
  resource_id = each.value.resource_id
  key         = each.value.key
  value       = each.value.value
}

resource "aws_ec2_tag" "public_subnet" {
  for_each    = local.public_subnet_tags
  resource_id = each.value.resource_id
  key         = each.value.key
  value       = each.value.value
}

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
      key_arn = var.kms_key_arn
    }
    resources = ["secrets"]
  }

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
    subnet_ids              = var.private_subnet_ids
  }

  depends_on = [
    aws_ec2_tag.private_subnet,
    aws_ec2_tag.public_subnet,
    aws_iam_role_policy_attachment.eks_cluster
  ]

  tags = merge({ Name = var.cluster_name }, var.tags)
}

resource "aws_security_group" "node" {
  name        = "${var.cluster_name}-node"
  description = "EKS node security group"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({ Name = "${var.cluster_name}-node" }, var.tags)
}

resource "aws_launch_template" "this" {
  for_each = var.node_groups

  name                   = "${var.cluster_name}-${each.key}-lt"
  image_id               = data.aws_ssm_parameter.eks_al2023.value
  update_default_version = true

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      delete_on_termination = true
      encrypted             = true
      kms_key_id            = var.kms_key_arn
      volume_size           = var.volume_size
      volume_type           = var.volume_type
    }
  }

  dynamic "tag_specifications" {
    for_each = local.tag_resource_types
    content {
      resource_type = tag_specifications.value
      tags          = { Name = "${var.cluster_name}-${each.key}" }
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    instance_metadata_tags      = "enabled"
    http_put_response_hop_limit = 2
  }

  network_interfaces {
    security_groups = [aws_security_group.node.id, aws_eks_cluster.this.vpc_config[0].cluster_security_group_id]
  }

  user_data = base64encode(templatefile("${path.module}/userdata.tpl", {
    CLUSTER_NAME         = aws_eks_cluster.this.name
    B64_CLUSTER_CA       = aws_eks_cluster.this.certificate_authority[0].data
    API_SERVER_URL       = aws_eks_cluster.this.endpoint
    CLUSTER_SERVICE_CIDR = var.eks_cluster_cidr
    CLUSTER_DNS_IP       = var.cluster_dns_ip
  }))

  tags = merge({ Name = "${var.cluster_name}-${each.key}-lt" }, var.tags)
}

resource "kubernetes_config_map_v1_data" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode(concat(
      [
        {
          rolearn  = aws_iam_role.eks_node.arn
          username = "system:node:{{EC2PrivateDNSName}}"
          groups   = ["system:bootstrappers", "system:nodes"]
        }
      ],
      var.map_roles
    ))
    mapUsers = yamlencode(var.map_users)
  }

  force = true

  depends_on = [aws_eks_cluster.this]
}

resource "aws_eks_node_group" "this" {
  for_each = var.node_groups

  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-${each.key}"
  node_role_arn   = aws_iam_role.eks_node.arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = each.value.desired_size
    max_size     = each.value.max_size
    min_size     = each.value.min_size
  }

  launch_template {
    id      = aws_launch_template.this[each.key].id
    version = aws_launch_template.this[each.key].latest_version
  }

  update_config {
    max_unavailable = 1
  }

  labels = each.value.labels

  instance_types = each.value.instance_types
  capacity_type  = each.value.capacity_type

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_node
  ]

  tags = merge(
    {
      Name                                            = "${var.cluster_name}-${each.key}"
      "k8s.io/cluster-autoscaler/enabled"             = "true"
      "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
    },
    var.tags
  )
}
