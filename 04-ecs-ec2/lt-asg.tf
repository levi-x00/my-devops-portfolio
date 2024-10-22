# ------------------------------------------------------------------------------------------
# bastion host section
# ------------------------------------------------------------------------------------------
resource "null_resource" "generate_key" {
  provisioner "local-exec" {
    command = <<EOT
    ssh-keygen -t rsa -b 4096 -f ${path.module}/ecs-kp
    EOT
  }
}

resource "aws_key_pair" "ecs_kp" {
  key_name   = "ecs-kp"
  public_key = file("${path.module}/ecs-kp.pub")
}

resource "aws_instance" "jumphost" {
  depends_on = [
    aws_iam_instance_profile.node_iam_profile
  ]

  ami           = data.aws_ami.amzn-linux-2023-ami.id
  instance_type = "t3.micro"

  subnet_id = local.lb_subnets[0]

  iam_instance_profile = "${var.cluster_name}-node-profile"

  tags = {
    Name = "jumphost"
  }
}

# ------------------------------------------------------------------------------------------
# ecs worker nodes section
# ------------------------------------------------------------------------------------------
resource "aws_launch_template" "lt" {
  depends_on = [
    aws_ecs_cluster.cluster,
    aws_key_pair.ecs_kp
  ]

  name          = "ecs-ec2-${var.environment}-lt"
  image_id      = data.aws_ami.amzlinux2.id
  instance_type = var.instance_type

  key_name = "ecs-kp"

  vpc_security_group_ids = [
    aws_security_group.node_sg.id
  ]

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = var.volume_size
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
    echo ECS_CLUSTER=${var.cluster_name} >> /etc/ecs/ecs.config
    EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = merge({
      Name = "ecs-ec2-${var.environment}"
    }, local.default_tags)
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge({
      Name = "ecs-ec2-${var.environment}"
    }, local.default_tags)
  }

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

  vpc_zone_identifier = local.prv_subnets
  health_check_type   = "EC2"

  protect_from_scale_in = true

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
    value               = true
    propagate_at_launch = true
  }

  tag {
    key                 = "ManagedBy"
    value               = "Terraform"
    propagate_at_launch = true
  }
}

# ------------------------------------------------------------------------------------------
# ecs capacity provder section
# ------------------------------------------------------------------------------------------
resource "aws_ecs_capacity_provider" "ecs_cp" {
  depends_on = [
    aws_ecs_cluster.cluster
  ]
  name = "${var.cluster_name}-cp"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.asg.arn
    managed_termination_protection = "ENABLED"

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
