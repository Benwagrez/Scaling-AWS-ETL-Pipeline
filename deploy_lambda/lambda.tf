# ========================== #
# = Lambda Function Deploy = #
# ========================== #
# Purpose
# Deploying Lambda function for the ETL Data Processor

resource "aws_lambda_function" "lambda_deploy" {
  image_uri     = "${var.ecr_url}:latest"
  function_name = var.etl_func_name
  role          = aws_iam_role.iam_for_etl_lambda.arn
  package_type  = "Image"

  timeout = 60

  # image_config {
  #   entry_point = "runner"
  # }

  tags = "${merge(
    var.common_tags,
    tomap({
      "Name" = "ETL_proc_action",
    })
  )}"
}
