variable "common_tags" {
  type = map(string)
  description = "Commong tags to provision on resources created in Terraform"
  default = {
      Infra = "ETL Pipeline",
      Owner = "benwagrez@gmail.com"
  }
}

variable "ecr_url" {
  type = string
}

variable "outputbucketid" {
  type = string
}

variable "data_output_bucket_name" {
  type = string
}

variable "caller_id" {
  type = string
}

variable "region" {
  type = string
}