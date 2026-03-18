##
## Define Log Group
##
resource "aws_cloudwatch_log_group" "nothub2" {
  name = "aws-waf-logs-mobility-collaboration-${var.environment}"
  tags = module.tags.all_tags
}

resource "aws_cloudwatch_log_resource_policy" "nothub2" {
  #provider = aws.prod_perimeter_us

  policy_name = "aws-waf-logs-mc-nothub2-${var.environment}"
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
        Resource = "${aws_cloudwatch_log_group.nothub2.arn}:*",
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
