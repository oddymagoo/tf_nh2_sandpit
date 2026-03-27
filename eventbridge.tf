resource "aws_cloudwatch_event_rule" "lambda_schedule" {
  name                = "my-lambda-weekday-schedule"
  description         = "Trigger Lambda at 20:00 UTC Monday–Friday"
  schedule_expression = "cron(0 20 ? * MON-FRI *)"
  #is_enabled          = true
  event_bus_name = "default"
}


resource "aws_cloudwatch_event_target" "lambda_target" {
  rule           = aws_cloudwatch_event_rule.lambda_schedule.name
  event_bus_name = "default"
  target_id      = "lambda"
  arn            = aws_lambda_function.my_lambda.arn
}
