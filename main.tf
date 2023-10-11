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
    Infra = var.deployvm ? "deploy_vm" : var.deploycontainer ? "deploy_container" : var.deploylambda ? "deploy_lambda" : ""
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
    acme = {
      source  = "vancluever/acme"
      version = "2.16.1"
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
# vm_batch_deployment        | For VM deployment - Depends on deployvm var
# container_batch_deployment | For container deployment - Depends on deploycontainer var

module "core_infra_deployment" {
  source = "./deploy_core"

  deployvm             = var.deployvm
  deploylambda         = var.deploylambda
  deploycontainer      = var.deploycontainer
  DataOutputBucketName = var.DataOutputBucketName
  common_tags          = local.common_tags
} 

module "lambda_batch_deployment" {
  count  = var.deploylambda ? 1 : 0
  source = "./deploy_lambda"

  outputbucketid   = module.core_infra_deployment.outputbucketid
  common_tags     = local.common_tags
} 

module "vm_batch_deployment" {
  count  = var.deployvm ? 1 : 0
  source = "./deploy_vm"

  outputbucketid   = module.core_infra_deployment.outputbucketid
  common_tags    = local.common_tags
}

module "container_batch_deployment" {
  count  = var.deploycontainer ? 1 : 0
  source = "./deploy_container"

  outputbucketid   = module.core_infra_deployment.outputbucketid
  common_tags    = local.common_tags
}
