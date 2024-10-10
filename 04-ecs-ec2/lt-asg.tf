resource "aws_launch_template" "lt" {
  depends_on = [
    aws_ecs_cluster.cluster
  ]

  name          = "ecs-ec2-${var.environment}-lt"
  image_id      = data.aws_ami.amzlinux2.id
  instance_type = var.instance_type

  vpc_security_group_ids = [
    aws_security_group.node_sg.id
  ]

  block_device_mappings {
    device_name = "/dev/sdf"
    ebs {
      volume_size = 16
      volume_type = "gp3"
      kms_key_id  = local.kms_key_arn
      encrypted   = true
    }
  }

  iam_instance_profile {
    arn = aws_iam_instance_profile.node_iam_profile.arn
  }

  monitoring {
    enabled = true
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo ECS_CLUSTER=${var.cluster_name} >> /etc/ecs/ecs.config;
    EOF
  )

  tags = {
    Name = "ecs-ec2-${var.environment}-lt"
  }
}

resource "aws_autoscaling_group" "asg" {
  depends_on = [
    aws_ecs_cluster.cluster
  ]

  name = "${var.cluster_name}-node"

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  vpc_zone_identifier  = local.prv_subnets
  health_check_type    = "EC2"
  termination_policies = ["OldestInstance"]

  launch_template {
    id      = aws_launch_template.lt.id
    version = aws_launch_template.lt.latest_version
  }

  lifecycle {
    ignore_changes = [
      desired_capacity
    ]
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 100
    }
    triggers = ["launch_template"]
  }

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}-node"
    propagate_at_launch = true
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = "true"
    propagate_at_launch = true
  }

  tag {
    key                 = "ManagedBy"
    value               = "Terraform"
    propagate_at_launch = true
  }
}

#################################### ECS Capacity Provider ###################################
resource "aws_ecs_capacity_provider" "ecs_cp" {
  depends_on = [
    aws_ecs_cluster.cluster
  ]
  name = "${var.cluster_name}-cp"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.asg.arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      maximum_scaling_step_size = 1
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 100
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "ecs_cp" {
  depends_on = [
    aws_ecs_cluster.cluster
  ]

  cluster_name       = var.cluster_name
  capacity_providers = [aws_ecs_capacity_provider.ecs_cp.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ecs_cp.name
    base              = 1
    weight            = 100
  }
}
