# ========================== #
# == SSM Parameter Deploy == #
# ========================== #
# Purpose
# Deploying SSM Parameter for Data Query Lambda to execute data processing action

resource "aws_ssm_parameter" "ContainerArn" {
  name  = "ETL Container Batch ARN"
  type  = "String"
  value = "etl_pipeline/batch_queue/${aws_batch_job_queue.ecs_queue.arn}"
}