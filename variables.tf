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

variable "TerraformSPNArn" {
  type = string
  description = "Arn of the service principal deploying the Terraform code (user owner of access key)."
}

variable "AWS_ACCESS_KEY" {
    type = string
}

variable "AWS_SECRET_KEY" {
    type = string
}

# Core Infra Variables

variable "DataInputBucketName" {
    type = string
}

variable "DataOutputBucketName" {
    type = string
}
