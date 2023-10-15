data "aws_iam_policy_document" "TerraformSPNPolicy" {
  statement {
    sid    = "AllowTerraformSPN"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["${var.TerraformSPNArn}"]
    }

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeRepositories",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages",
      "ecr:DeleteRepository",
      "ecr:BatchDeleteImage",
      "ecr:SetRepositoryPolicy",
      "ecr:DeleteRepositoryPolicy",
    ]
  }
}