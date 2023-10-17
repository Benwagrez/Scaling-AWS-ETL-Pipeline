
variable "outputbucketid" {
	type = string
	default = ""
}

variable "ecr_url" {
  type = string
}

variable "etl_func_name" {
    type = string
}

variable "common_tags" {
  type = map(string)
  description = "Commong tags to provision on resources created in Terraform"
  default = {
		Infra = "ETL Pipeline",
		Owner = "benwagrez@gmail.com"
  }
}
