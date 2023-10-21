# ========================= #
# ===== IAM resources ===== #
# ========================= #
# Purpose
# Deploying IAM resources to allow Lambda to execute actions on an S3 bucket and Athena

# Reference iam policy for sts:AssumeRole to attach to Lambda IAM role
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# Create IAM role for Lambda funtion
resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Created S3 access Policy for IAM Role
resource "aws_iam_policy" "policy" {
  name = "LambdaS3AccessPolicy"
  description = "Access policy granting Lambda access to S3 bucket where data will go through the ETL process as well as EC2 instance actions."

  policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Action": [
				"logs:*"
			],
			"Resource": "arn:aws:logs:*:*:*"
		},
		{
			"Effect": "Allow",
			"Action": [
				"s3:PutObject",
				"s3:GetObject",
				"s3:ListObjects",
				"s3:ListBucket",
				"s3:ListAllMyBuckets",
				"s3:GetObjectAttributes"
			],
			"Resource": [ "arn:aws:s3:::${var.data_output_bucket_name}/*", "arn:aws:s3:::${var.data_output_bucket_name}"]
		},
		{
			"Effect": "Allow",
			"Action": [
				"s3:GetBucketLocation"
			],
			"Resource": "arn:aws:s3:::*"
		},
		{
      "Effect": "Allow",
      "Action": [
        "ec2:Start*",
        "ec2:Stop*",
				"ec2:DescribeInstances"
      ],
      "Resource": "*"
    }
	]
} 
	EOF
}

# Attaching iam role to lambda action policy
resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = "${aws_iam_role.iam_for_lambda.name}"
  policy_arn = "${aws_iam_policy.policy.arn}"
}

# Data Visualization SPN IAM
resource "aws_iam_policy" "data_visualization_policy" {
  name        = "data_visualization_policy"
  description = "data visualization policy for Tableau SPN"

  # Terraform expression result to valid JSON syntax.
  policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetObject",
				"s3:GetBucketLocation",
				"s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [ 
				"arn:aws:s3:::${var.data_output_bucket_name}/*",
				"arn:aws:s3:::${var.data_output_bucket_name}" 
			]
    },
    {
      "Action": [
        "s3:GetObject",
				"s3:GetBucketLocation",
				"s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [ 
				"arn:aws:s3:::${var.dev_data_output_bucket_name}/*",
				"arn:aws:s3:::${var.dev_data_output_bucket_name}" 
			]
    }
  ]
}
EOT
}

resource "aws_iam_policy_attachment" "data_visualization_attach" {
    name = "data-visualization-attach"
    groups = [ aws_iam_group.data_visualization_group.name ]
    policy_arn = aws_iam_policy.data_visualization_policy.arn
}