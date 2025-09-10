resource "aws_wafv2_web_acl" "ecs_lb_waf" {
  name  = "ecs-lb-waf"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name = "rule-1"

    priority = 1

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"

        rule_action_override {
          action_to_use {
            count {}
          }

          name = "SizeRestrictions_QUERYSTRING"
        }

        rule_action_override {
          action_to_use {
            count {}
          }

          name = "NoUserAgent_HEADER"
        }

        scope_down_statement {
          geo_match_statement {
            country_codes = ["US", "NL"]
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "ecs-lb-waf"
      sampled_requests_enabled   = false
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "ecs-lb-waf"
    sampled_requests_enabled   = false
  }

  tags = {
    Name = "ecs-lb-waf"
  }
}

resource "aws_cloudwatch_log_group" "waf_logs" {
  name       = "aws-waf-logs-ecs"
  kms_key_id = local.kms_key_arn

  retention_in_days = var.retention_days
  tags = {
    Name = "aws-waf-logs-ecs"
  }
}

resource "aws_wafv2_web_acl_logging_configuration" "waf_log_conf" {
  log_destination_configs = [
    aws_cloudwatch_log_group.waf_logs.arn
  ]
  resource_arn = aws_wafv2_web_acl.ecs_lb_waf.arn
}

resource "aws_wafv2_web_acl_association" "waf-alb" {
  resource_arn = aws_lb.cluster.arn
  web_acl_arn  = aws_wafv2_web_acl.ecs_lb_waf.arn
}
