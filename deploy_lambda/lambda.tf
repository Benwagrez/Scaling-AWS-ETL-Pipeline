# ========================== #
# = Lambda Function Deploy = #
# ========================== #
# Purpose
# Deploying Lambda function for the visitor notification system
# Includes a zipped file payload of the python code

resource "aws_lambda_function" "lambda_deploy" {
  filename      = "${path.module}/../ETL_proc_action_payload.zip"
  function_name = "VisitorNotificationSystem"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_function.lambda_handler"

  source_code_hash = filemd5("${path.module}/../ETL_proc_action_payload.zip")

  runtime = "python3.9"
  timeout = 60
  environment {
    variables = {
      bucketname = var.outputbucketid
    }
  }

  tags = "${merge(
    var.common_tags,
    tomap({
      "Name" = "ETL_proc_action",
    })
  )}"
}
