# ========================= #
# ===== Main Executor ===== #
# ========================= #
# Purpose
# Manage all instantiated modules and providers
#
# Notes
# This module manager gives a holistic view on the environment being deployed through IAC. It provides documentation,
# clear and concise variables, and is easy to read for the purposes of understanding the code in the repo.

locals {
  common_tags = {
    Infra = var.deploycontainer ? "deploy_container" : var.deploylambda ? "deploy_lambda" : "" #var.deployvm ? "deploy_vm" : 
    Owner = "benwagrez@gmail.com"
  }
}

#############################
###### Provider Config ######
#############################
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# AWS Provider
provider "aws" {
  region     = var.region
  access_key = var.AWS_ACCESS_KEY
  secret_key = var.AWS_SECRET_KEY
}

# Random module - TODO incorporate more randomness
provider "random" {
}


#############################
###### Module Manager #######
#############################
# Below module dependencies are listed #
# ------------------------------------ #
# core_infra_deployment      | For Core Infrastructure deployment - default across all deployment types
# lambda_batch_deployment    | For lambda deployment - Depends on deploylambda var
# vm_deployment              | For VM deployment - Depends on deployvm var
# container_batch_deployment | For container deployment - Depends on deploycontainer var

module "core_infra_deployment" {
  source = "./deploy_core"

  job_queue_arn               = var.deploycontainer ? module.container_batch_deployment[0].job_queue_arn : null
  job_definition_arn          = var.deploycontainer ? module.container_batch_deployment[0].job_definition_arn : null
  etl_func_name               = var.etl_func_name
  prod_clients                = var.prod_clients
  region                      = var.region
  TerraformSPNArn             = data.aws_caller_identity.current.arn
  deployvm                    = var.deployvm
  deploylambda                = var.deploylambda
  deploycontainer             = var.deploycontainer
  data_output_bucket_name     = var.data_output_bucket_name
  dev_data_output_bucket_name = var.dev_data_output_bucket_name
  common_tags                 = local.common_tags
} 


module "vm_deployment" {
  count  = var.deployvm ? 1 : 0
  source = "./deploy_vm"

  region                      = var.region
  prod_clients                = var.prod_clients
  caller_id                   = data.aws_caller_identity.current.account_id
  prod_instance_type          = var.prod_instance_type
  dev_instance_type           = var.dev_instance_type
  data_output_bucket_name     = var.data_output_bucket_name
  dev_data_output_bucket_name = var.dev_data_output_bucket_name
  prod_ssh_public_key         = var.prod_ssh_public_key
  dev_ssh_public_key          = var.dev_ssh_public_key
  common_tags                 = local.common_tags
}

module "lambda_deployment" {
  count  = var.deploylambda ? 1 : 0
  source = "./deploy_lambda"

  etl_func_name  = var.etl_func_name
  ecr_url        = module.container_registry_deployment[0].ecr_repo_url
  outputbucketid = module.core_infra_deployment.outputbucketid
  common_tags    = local.common_tags
} 

module "container_registry_deployment" {
  count  = var.deploylambda ? 1 : var.deploycontainer ? 1 : var.deploycontainerregistry ? 1 : 0
  source = "./deploy_ecr"

  ecr_repo_name   = var.ecr_repo_name
  TerraformSPNArn = data.aws_caller_identity.current.arn
  common_tags     = local.common_tags
} 


module "container_batch_deployment" {
  count  = var.deploycontainer ? 1 : 0
  source = "./deploy_container"

  region                  = var.region
  data_output_bucket_name = var.data_output_bucket_name
  caller_id               = data.aws_caller_identity.current.account_id
  ecr_url                 = module.container_registry_deployment[0].ecr_repo_url
  outputbucketid          = module.core_infra_deployment.outputbucketid
  common_tags             = local.common_tags
}
