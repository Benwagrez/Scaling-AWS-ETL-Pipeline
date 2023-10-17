# ========================== #
# = Lambda Function Deploy = #
# ========================== #
# Purpose
# Deploying Lambda function for the visitor notification system
# Includes a zipped file payload of the python code

resource "aws_lambda_function" "lambda_deploy" {
  image_uri     = "${var.ecr_url}:latest"
  function_name = "DataProcessor"
  role          = aws_iam_role.iam_for_lambda.arn

  timeout = 60
  environment {
    variables = {
      bucketname = var.outputbucketid
    }
  }

  image_config {
    entry_point = "action"
  }

  tags = "${merge(
    var.common_tags,
    tomap({
      "Name" = "ETL_proc_action",
    })
  )}"
}
