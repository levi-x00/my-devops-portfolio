#------------------------------------------------------------------------------------------------------
# event bridge section
#------------------------------------------------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "codebuild_status_change" {
  name          = "codebuild-state-changes-rule"
  description   = "Triggers on CodeBuild build status changes for success and failure."
  role_arn      = aws_iam_role.event_publish_role.arn
  event_pattern = <<EOF
{
  "source": ["aws.codebuild"],
  "detail-type": ["CodeBuild Build State Change"],
  "detail": {
    "build-status": ["SUCCEEDED", "FAILED"]
  }
}
EOF
}

resource "aws_cloudwatch_event_target" "send_to_sns" {
  rule      = aws_cloudwatch_event_rule.codebuild_status_change.name
  target_id = aws_sns_topic.topic.name
  arn       = aws_sns_topic.topic.arn
}
