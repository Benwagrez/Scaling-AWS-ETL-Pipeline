output "ecr_arn" {
  value = aws_ecr_repository.r_ecr_repo.arn 
}

output "ecr_repo_url" {
  value = aws_ecr_repository.r_ecr_repo.repository_url 
}