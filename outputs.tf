output "ecr_repo_url" {
  value = module.container_registry_deployment.*.ecr_repo_url 
}