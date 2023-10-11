# ========================== #
# == SSM Parameter Deploy == #
# ========================== #
# Purpose
# Deploying SSM Parameter for Data Query Lambda to execute data processing action

resource "aws_ssm_parameter" "LambdaArn" {
  name  = "ETL Lambda Function ARN"
  type  = "String"
  value = "Null"
}