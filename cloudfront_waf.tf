##
## CloudFront WAF
##
resource "aws_wafv2_web_acl" "web_portal" {
  provider = aws.prod_perimeter_us

  name        = "${var.environment}_WebACLv2"
  description = "WebACL associated to Mobility Collaboration CloudFront Infrastructure"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  ## Rule: Geo-blocking or IP Set Blocking
  ##
  rule {
    name     = "Custom_GeoRestrictions"
    priority = 1

    action {
      block {}
    }

    statement {
      not_statement {
        statement {
          geo_match_statement {
            country_codes = var.allowed_countries
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.environment}-georestrictions-metrics"
      sampled_requests_enabled   = true
    }
  }

  ## Rule: AWS Common Rule Set
  ##
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.environment}-commonruleset-metrics"
      sampled_requests_enabled   = true
    }
  }

  ## Rule: Amazon IP-Reputation List
  ##
  rule {
    name     = "AWSManagedRulesAmazonIpReputationList"
    priority = 3

    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.environment}-amazonipreputationlistruleset-metrics"
      sampled_requests_enabled   = true
    }
  }

  ## Rule: Anonymous IP List
  ##
  rule {
    name     = "AWSManagedRulesAnonymousIpList"
    priority = 4

    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAnonymousIpList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.environment}-anonymousiplist-metrics"
      sampled_requests_enabled   = true
    }
  }

  ## Rule: Bot Control (Optional)
  ##
  rule {
    name     = "AWSManagedRulesBotControlRuleSetCommon"
    priority = 5

    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesBotControlRuleSet"
        vendor_name = "AWS"

        managed_rule_group_configs {
          aws_managed_rules_bot_control_rule_set {
            inspection_level = "COMMON"
          }
        }
        rule_action_override {
          name = "SignalNonBrowserUserAgent"
          action_to_use {
            count {}
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.environment}-botcontrolruleset-common-metrics"
      sampled_requests_enabled   = true
    }
  }

  ## Rule: Rate-based rule
  ##
  rule {
    name     = "Custom_RateBased"
    priority = 6

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 10000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.environment}-ratebased-metrics"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.environment}-webacl-metrics"
    sampled_requests_enabled   = true
  }

  tags = module.tags.all_tags
}

## CloudWatch Log Group for WAF Logs
##
resource "aws_cloudwatch_log_group" "web_portal" {
  provider = aws.prod_perimeter_us

  name = "aws-waf-logs-${var.environment}"
  tags = module.tags.all_tags
}

resource "aws_cloudwatch_log_resource_policy" "web_portal" {
  provider = aws.prod_perimeter_us

  policy_name = "aws-waf-logs-${var.environment}"
  policy_document = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        },
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "${aws_cloudwatch_log_group.web_portal.arn}:*",
        Condition = {
          ArnLike = {
            "aws:SourceArn" = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
          },
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

resource "aws_wafv2_web_acl_logging_configuration" "web_portal" {
  provider = aws.prod_perimeter_us

  log_destination_configs = [aws_cloudwatch_log_group.web_portal.arn]
  resource_arn            = aws_wafv2_web_acl.web_portal.arn
  depends_on = [ aws_cloudwatch_log_resource_policy.web_portal ]
}