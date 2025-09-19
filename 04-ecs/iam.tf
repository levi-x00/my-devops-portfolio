data "aws_iam_policy_document" "ecs_instance_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type = "Service"
      identifiers = [
        "ec2.amazonaws.com",
        "ecs.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "ecs_instance_role" {
  name               = "ecs-instance-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_instance_role_policy.json
}

resource "aws_iam_role_policy_attachments_exclusive" "ecs_instance_policies" {
  role_name = aws_iam_role.ecs_instance_role.name
  policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM",
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  ]
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecs-instance-role"
  role = aws_iam_role.ecs_instance_role.id
}


