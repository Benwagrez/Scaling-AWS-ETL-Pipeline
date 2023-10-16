output "ecr_repo_url" {
  value = module.container_registry_deployment.*.ecr_repo_url 
}

output "tableau_spn_name" {
  value = module.core_infra_deployment.tableau_spn_name 
}

output "outputbucketid" {
  value = module.core_infra_deployment.outputbucketid
}