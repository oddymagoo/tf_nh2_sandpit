resource "aws_lambda_function" "hello_world_function" {
  function_name = "helloworld"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"

  filename         = "/config/data/tf_nh2_sandpit/lambda/helloworld.zip"
  source_code_hash = filebase64sha256("/config/data/tf_nh2_sandpit/lambda/helloworld.zip")

  environment {
    variables = {
      DYNAMODB_TABLE = "hc3_app_content_table_dev"
      #When using SNS, update the following:
      #PLATFORM_ENDPOINT = "arn:aws:sns:ap-southeast-2:252152158302:app/APNS/hazchat3-prod"
    }
  }

  logging_config {
    log_format = "Text"
  }

  timeout     = 10
  memory_size = 128
}


resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "xxxxx"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello_world_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_schedule.arn
}


/*
#event_source_arn  = "arn:aws:dynamodb:ap-southeast-2:252152158302:table/hazchat-3-person-table-prod/stream/latest"
resource "aws_lambda_event_source_mapping" "dynamodb_trigger" {
  event_source_arn                   = aws_dynamodb_table.hc3_app_content_table_dev.stream_arn
  function_name                      = aws_lambda_function.hello_world_function.arn
  starting_position                  = "LATEST"
  batch_size                         = 100
  maximum_batching_window_in_seconds = 0
  #maximum_concurrent_batches         = 1  
}
*/