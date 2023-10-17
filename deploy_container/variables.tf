variable "common_tags" {
  type = map(string)
  description = "Commong tags to provision on resources created in Terraform"
  default = {
      Infra = "ETL Pipeline",
      Owner = "benwagrez@gmail.com"
  }
}

variable "outputbucketid" {
  type = string
}