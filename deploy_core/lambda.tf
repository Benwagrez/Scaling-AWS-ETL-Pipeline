# ========================== #
# = Lambda Function Deploy = #
# ========================== #
# Purpose
# Deploying Lambda function for the ETL Data Query
# Includes a zipped file payload of the python code

resource "aws_lambda_function" "lambda_deploy" {
  filename      = "${path.module}/../ETL_data_query_payload.zip"
  function_name = "ETLDataQuery"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_function.lambda_handler"

  source_code_hash = filemd5("${path.module}/../ETL_data_query_payload.zip")

  runtime = "python3.11"
  timeout = 30
  environment {
    variables = {
      inputbucketname = var.DataInputBucketName
      cronjobcadence  = var.DataQueryCadence
      deployvm        = var.deployvm
      deploylambda    = var.deploylambda
      deploycontainer = var.deploycontainer
    }
  }

  tags = "${merge(
    var.common_tags,
    tomap({
      "Name" = "ETLDataQuery",
    })
  )}"
}

resource "aws_lambda_permission" "cw_call_data_query" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda_deploy.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.data_pull_cron.arn}"
}