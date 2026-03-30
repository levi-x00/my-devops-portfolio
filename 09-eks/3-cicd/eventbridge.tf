########################################################################
# EventBridge — trigger backend pipeline on CodeCommit push
########################################################################
resource "aws_cloudwatch_event_rule" "backend" {
  name        = "${var.cluster_name}-backend-pipeline-trigger"
  description = "Trigger backend pipeline on push to ${var.backend_repository_name}/${var.branch_name}"

  event_pattern = jsonencode({
    source      = ["aws.codecommit"]
    detail-type = ["CodeCommit Repository State Change"]
    resources   = [aws_codecommit_repository.backend.arn]
    detail = {
      event         = ["referenceCreated", "referenceUpdated"]
      referenceType = ["branch"]
      referenceName = [var.branch_name]
    }
  })
}

resource "aws_cloudwatch_event_target" "backend" {
  rule     = aws_cloudwatch_event_rule.backend.name
  arn      = module.backend_pipeline.arn
  role_arn = aws_iam_role.eventbridge.arn
}

########################################################################
# EventBridge — trigger frontend pipeline on CodeCommit push
########################################################################
resource "aws_cloudwatch_event_rule" "frontend" {
  name        = "${var.cluster_name}-frontend-pipeline-trigger"
  description = "Trigger frontend pipeline on push to ${var.frontend_repository_name}/${var.branch_name}"

  event_pattern = jsonencode({
    source      = ["aws.codecommit"]
    detail-type = ["CodeCommit Repository State Change"]
    resources   = [aws_codecommit_repository.frontend.arn]
    detail = {
      event         = ["referenceCreated", "referenceUpdated"]
      referenceType = ["branch"]
      referenceName = [var.branch_name]
    }
  })
}

resource "aws_cloudwatch_event_target" "frontend" {
  rule     = aws_cloudwatch_event_rule.frontend.name
  arn      = module.frontend_pipeline.arn
  role_arn = aws_iam_role.eventbridge.arn
}

########################################################################
# IAM Role for EventBridge to trigger CodePipeline
########################################################################
resource "aws_iam_role" "eventbridge" {
  name = "${var.cluster_name}-eventbridge-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "events.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "eventbridge" {
  name = "eventbridge-inline-policy"
  role = aws_iam_role.eventbridge.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "codepipeline:StartPipelineExecution"
      Resource = [
        module.backend_pipeline.arn,
        module.frontend_pipeline.arn
      ]
    }]
  })
}
