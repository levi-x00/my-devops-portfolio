locals {
  create_role = var.create_role
}

data "aws_iam_policy_document" "assume_role" {
  count = local.create_role ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  count              = local.create_role ? 1 : 0
  name               = "${var.name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role[0].json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = local.create_role ? toset(var.policy_arns) : toset([])

  role       = aws_iam_role.this[0].name
  policy_arn = each.value
}

resource "aws_codepipeline" "this" {
  name     = var.name
  role_arn = local.create_role ? aws_iam_role.this[0].arn : var.iam_role_arn

  dynamic "artifact_store" {
    for_each = length(var.artifact_store) > 0 ? var.artifact_store : []

    content {
      location = artifact_store.value.location
      type     = artifact_store.value.type
    }
  }

  dynamic "stage" {
    for_each = length(var.stage) > 0 && var.stage != null ? var.stage : []

    content {
      name = stage.value.name
      action {
        name             = stage.value.action_name
        category         = stage.value.category
        owner            = stage.value.owner
        provider         = stage.value.provider
        version          = stage.value.version
        namespace        = try(stage.value.namespace, null)
        run_order        = try(stage.value.run_order, null)
        role_arn         = try(stage.value.role_arn, null)
        region           = try(stage.value.region, null)
        input_artifacts  = try(stage.value.input_artifacts, [])
        output_artifacts = try(stage.value.output_artifacts, [])
        configuration    = try(stage.value.configuration, null)
      }
    }
  }

  tags = var.tags
}
