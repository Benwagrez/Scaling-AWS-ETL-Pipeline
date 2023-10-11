# ========================= #
# == Event Hub Resources == #
# ========================= #
# Purpose
# To deploy an AWS Event Hub Cron Job to execute the Lambda function every day

resource "aws_cloudwatch_event_rule" "data_pull_cron" {
  name                = "data_pull_cron_job"
  description         = "Data pull cron job to pull data from source into S3 bucket"
  schedule_expression = "rate(${var.DataQueryCadence})"
}

resource "aws_cloudwatch_event_target" "delete_old_amis" {
  rule      = "${aws_cloudwatch_event_rule.data_pull_cron.name}"
  target_id = "lambda"
  arn       = "${aws_lambda_function.lambda_deploy.arn}"
}