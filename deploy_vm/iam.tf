# ========================= #
# ====== IAM details ====== #
# ========================= #
# Purpose
# Giving the EC2 instance IAM permissions for:
# SSM params, S3 bucket, STS Assume Role

# IAM policy for EC2 instance to run Put, Get, List, and Delete on created S3 buckets
resource "aws_iam_policy" "bucket_policy" {
  name        = "web-bucket-policy"
  path        = "/"
  description = "Allow "

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
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
          "arn:aws:s3:::${var.DataOutputBucketName}/*",
          "arn:aws:s3:::${var.DataOutputBucketName}"
        ]
      }
    ]
  })
}

# IAM role for EC2 instance that allows it to communicate with the STS service to assume role
resource "aws_iam_role" "ec2_data_role" {
  name = "ec2_web_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

# IAM policy giving EC2 instance SSM Get rights for git connection string
resource "aws_iam_policy" "ssm_policy" {
  name        = "ssm-policy"
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
            "Resource": "arn:aws:ssm:us-east-2:${var.CallerID}:parameter/git/*"
        }
    ]
  })  
}


# Attaching policies to role and role an EC2 instance profile
resource "aws_iam_role_policy_attachment" "bucket_policy_role_attachment" {
  role       = aws_iam_role.ec2_data_role.name
  policy_arn = aws_iam_policy.bucket_policy.arn
}

resource "aws_iam_role_policy_attachment" "ssm_policy_role_attachment" {
  role       = aws_iam_role.ec2_data_role.name
  policy_arn = aws_iam_policy.ssm_policy.arn
}

resource "aws_iam_instance_profile" "ec2_data_profile" {
  name = "ec2-data-profile"
  role = aws_iam_role.ec2_data_role.name
}


