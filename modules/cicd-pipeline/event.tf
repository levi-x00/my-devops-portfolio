resource "aws_cloudwatch_event_rule" "pipeline_trigger" {
  name        = "${var.service_name}-pipeline"
  description = "Capture each AWS Console Sign In"

  event_pattern = jsonencode(
    {
      "source" : [
        "aws.codecommit"
      ],
      "detail-type" : [
        "CodeCommit Repository State Change"
      ],
      "resources" : [
        "arn:aws:codecommit:${local.region}:${local.account_id}:${var.repository_name}"
      ],
      "detail" : {
        "event" : ["referenceCreated", "referenceUpdated"],
        "referenceType" : [
          "branch"
        ],
        "referenceName" : [
          "master"
        ]
      }
  })
}

data "aws_iam_policy_document" "event_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "event_iam_policy" {
  statement {
    actions   = ["codepipeline:StartPipelineExecution"]
    resources = ["*"]
  }
}

resource "aws_iam_role" "event_iam_role" {
  name               = "${var.service_name}-event-iam-role"
  assume_role_policy = data.aws_iam_policy_document.event_assume_role.json

  inline_policy {
    name   = "pipeline-invocation-policy"
    policy = data.aws_iam_policy_document.event_iam_policy.json
  }
}

resource "aws_cloudwatch_event_target" "pipeline_trigger" {
  rule      = aws_cloudwatch_event_rule.pipeline_trigger.name
  target_id = "${var.service_name}-trigger"
  arn       = aws_codepipeline.pipeline.arn
  role_arn  = aws_iam_role.event_iam_role.arn
}
