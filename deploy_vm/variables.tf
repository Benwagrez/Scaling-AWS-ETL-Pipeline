variable "common_tags" {
  type = map(string)
  description = "Commong tags to provision on resources created in Terraform"
  default = {
      Infra = "deploy_vm",
      Owner = "benwagrez@gmail.com"
  }
}

variable "region" {
  type = string
}

variable "caller_id" {
  type = string
}

variable "sshpublickey" {
  type = string
}

variable "data_output_bucket_name"{
  type = string
}

variable "dev_data_output_bucket_name" {
  type = string
  description = "Name of the dev ETL output bucket"
}

variable "prod_instance_type" {
    type = string
}

variable "dev_instance_type" {
    type = string
}

variable "prod_clients" {
  type = list(object({
    Name = string
    GitConnectionString = string
  }))
}