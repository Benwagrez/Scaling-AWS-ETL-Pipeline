
data "aws_iam_policy_document" "batch_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["batch.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "aws_batch_service_role" {
  name               = "aws_batch_service_role"
  assume_role_policy = data.aws_iam_policy_document.batch_assume_role.json
}

resource "aws_iam_role_policy_attachment" "aws_batch_service_role" {
  role       = aws_iam_role.aws_batch_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecs_task_exec_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Job Role ARN
resource "aws_iam_role" "ecs_data_role" {
  name = "ecs_data_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect":"Allow",
        "Principal":{
          "Service":[
            "ecs-tasks.amazonaws.com"
          ]
        },
        "Action":"sts:AssumeRole",
        "Condition":{
          "ArnLike":{
          "aws:SourceArn":"arn:aws:ecs:${var.region}:${var.caller_id}:*"
          },
          "StringEquals":{
            "aws:SourceAccount":"${var.caller_id}"
          }
        }
      }
    ]
  })
}

# IAM policy giving EC2 instance EC2 manipulation rights
# IAM policy for EC2 instance to run Put, Get, List, and Delete on created S3 buckets
# IAM policy giving EC2 instance SSM Get rights for git connection string
resource "aws_iam_policy" "ecs_data_policy" {
  name        = "ecs-prod-data-policy"
  path        = "/"
  description = "Allow"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameters",
                "ssm:GetParameter"
            ],
            "Resource": "arn:aws:ssm:${var.region}:${var.caller_id}:parameter/git/*"
        },
        {
          "Sid" : "AllowDeployBucket",
          "Effect" : "Allow",
          "Action" : [
            "s3:PutObject",
            "s3:GetObject",
            "s3:ListBucket",
            "s3:DeleteObject",
            "s3:GetBucketLocation"
          ],
          "Resource" : [
            "arn:aws:s3:::${var.data_output_bucket_name}/*",
            "arn:aws:s3:::${var.data_output_bucket_name}"
          ]
        }
    ]
  })  
}


# Attaching policies to role and role an EC2 instance profile
resource "aws_iam_role_policy_attachment" "ecs_policy_role_attachment" {
  role       = aws_iam_role.ecs_data_role.name
  policy_arn = aws_iam_policy.ecs_data_policy.arn
}