# Deployment Specific Variables

variable "deployvm" {
    type = bool
    default = false
}

variable "deploylambda" {
    type = bool
    default = false
}

variable "deploycontainer" {
    type = bool
    default = false
}

variable "deploycontainerregistry" {
    type = bool
    default = false
}

variable "TerraformSPNArn" {
  type = string
  description = "Arn of the service principal deploying the Terraform code (user owner of access key)."
}

variable "region" {
    type = string
}

variable "AWS_ACCESS_KEY" {
    type = string
}

variable "AWS_SECRET_KEY" {
    type = string
}

# Core Infra Variables

variable "DataOutputBucketName" {
    type = string
}

# Container Registry Variables

variable "ecr_repo_name" {
    type = string
}

# VM Variables

variable "sshpublickey" {
    type = string
}

variable "instance_type" {
    type = string
}

variable "prod_clients" {
  type = list(object({
    Name = string
    GitConnectionString = string
  }))
}