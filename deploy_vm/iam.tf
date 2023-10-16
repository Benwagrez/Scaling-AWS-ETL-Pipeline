# ========================= #
# ====== IAM details ====== #
# ========================= #
# Purpose
# Giving the EC2 instance IAM permissions for:
# SSM params, S3 bucket, STS Assume Role

# Prod looped iam roles
# IAM role for EC2 instance that allows it to communicate with the STS service to assume role
resource "aws_iam_role" "ec2_data_role" {
  for_each   = {
    for index, client in var.prod_clients:
    client.Name => client
  }

  name = "ec2_${each.value.Name}_data_role"

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

# IAM policy giving EC2 instance EC2 manipulation rights
# IAM policy for EC2 instance to run Put, Get, List, and Delete on created S3 buckets
# IAM policy giving EC2 instance SSM Get rights for git connection string
resource "aws_iam_policy" "data_policy" {
  for_each   = {
    for index, client in var.prod_clients:
    client.Name => client
  }

  name        = "${each.value.Name}-prod-data-policy"
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
            "Resource": "arn:aws:ssm:${var.region}:${var.caller_id}:parameter/git/${each.value.Name}"
        },
        {
          "Effect": "Allow",
          "Action": [
            "ec2:Stop*"
          ],
          "Resource": "arn:aws:ec2:*:*:instance/*",
          "Condition": {
              "StringEquals": {"aws:ResourceTag/UUID": "${base64encode(each.value.Name)}"}
          }
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
resource "aws_iam_role_policy_attachment" "prod_policy_role_attachment" {
  for_each   = {
    for index, client in var.prod_clients:
    client.Name => client
  }

  role       = aws_iam_role.ec2_data_role[each.value.Name].name
  policy_arn = aws_iam_policy.data_policy[each.value.Name].arn
}

resource "aws_iam_instance_profile" "ec2_data_profile" {
  for_each   = {
    for index, client in var.prod_clients:
    client.Name => client
  }

  name = "ec2-${each.value.Name}-data-profile"
  role = aws_iam_role.ec2_data_role[each.value.Name].name

  depends_on = [ aws_iam_role_policy_attachment.prod_policy_role_attachment ]
}

# Dev instance IAM details

resource "aws_iam_role" "ec2_dev_data_role" {
  name = "ec2_data_role"

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

# IAM policy for EC2 instance to run Put, Get, List, and Delete on created S3 buckets
resource "aws_iam_policy" "dev_data_policy" {
  name        = "dev-data-policy"
  path        = "/"
  description = "Allow"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
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
            "arn:aws:s3:::${var.dev_data_output_bucket_name}/*",
            "arn:aws:s3:::${var.dev_data_output_bucket_name}"
          ]
        }
    ]
  })  
}


# Attaching policies to role and role an EC2 instance profile
resource "aws_iam_role_policy_attachment" "dev_policy_role_attachment" {
  role       = aws_iam_role.ec2_dev_data_role.name
  policy_arn = aws_iam_policy.dev_data_policy.arn
}

resource "aws_iam_instance_profile" "ec2_dev_data_profile" {
  name = "ec2-dev-data-profile"
  role = aws_iam_role.ec2_dev_data_role.name

  depends_on = [ aws_iam_role_policy_attachment.dev_policy_role_attachment ]
}


