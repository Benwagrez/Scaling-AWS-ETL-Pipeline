variable "common_tags" {
  type = map(string)
  description = "Commong tags to provision on resources created in Terraform"
  default = {
      Infra = "deploy_vm",
      Owner = "benwagrez@gmail.com"
  }
}

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

variable "DataQueryCadence" {
  type = string
  default = "1 day"
  description = "Name of the ETL input bucket"
}

variable "DataInputBucketName" {
  type = string
  description = "Name of the ETL input bucket"
}

variable "DataOutputBucketName" {
  type = string
  description = "Name of the ETL output bucket"
}