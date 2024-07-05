resource "aws_launch_template" "eks_ng" {
  name          = "eks-ng"
  ebs_optimized = true
  instance_type = "t3.micro"
  key_name      = "eks-ng-key"

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 8
      volume_type           = "gp2"
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
      Name = "eks-ng"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = "eks-ng"
    }
  }

  tags = {
    Name = "eks-ng"
  }
}

resource "aws_eks_node_group" "eks_ng" {
  cluster_name = aws_eks_cluster.cluster.name

  node_group_name = "eks-ng"
  node_role_arn   = aws_iam_role.eks_ng_role.arn
  subnet_ids      = data.terraform_remote_state.network.outputs.private_subnet_ids

  #version = var.cluster_version #(Optional: Defaults to EKS Cluster Kubernetes version)    

  ami_type      = "AL2_x86_64"
  capacity_type = "ON_DEMAND"

  launch_template {
    id      = aws_launch_template.eks_ng.id
    version = "$Latest"
  }

  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 2
  }

  update_config {
    max_unavailable = 1
    #max_unavailable_percentage = 50    # ANY ONE TO USE
  }

  depends_on = [
    aws_iam_role_policy_attachment.worker_node,
    aws_iam_role_policy_attachment.cni,
    aws_iam_role_policy_attachment.ec2_container_reg_read_only,
  ]

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  tags = {
    Name = "eks-ng"
  }
}
