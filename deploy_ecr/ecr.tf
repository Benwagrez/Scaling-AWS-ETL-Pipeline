# ========================================== #
# === Elastic Container Registry details === #
# ========================================== #
# Purpose
# Deploy Elastic container registry to hold docker images for lambda and batch deployments
#
############################################
########### Container Registry #############
############################################

resource "aws_ecr_repository" "r_ecr_repo" {
  name                 = var.ecr_repo_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository_policy" "TerraformSPNPolicy" {
  repository = aws_ecr_repository.r_ecr_repo.name
  policy     = data.aws_iam_policy_document.TerraformSPNPolicy.json
}