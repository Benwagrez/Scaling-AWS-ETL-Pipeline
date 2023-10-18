variable "common_tags" {
  type = map(string)
  description = "Commong tags to provision on resources created in Terraform"
  default = {
      Infra = "ETL Pipeline",
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

variable "data_output_bucket_name" {
  type = string
  description = "Name of the ETL output bucket"
}

variable "dev_data_output_bucket_name" {
  type = string
  description = "Name of the dev ETL output bucket"
}

variable "job_queue_arn" {
  type     = string
  nullable = true
}

variable "job_definition_arn" {
  type     = string
  nullable = true
}

variable "region" {
  type = string  
}

variable "etl_func_name" {
    type     = string
    nullable = true
}

variable "prod_clients" {
  type = list(object({
    Name = string
    GitConnectionString = string
  }))
}