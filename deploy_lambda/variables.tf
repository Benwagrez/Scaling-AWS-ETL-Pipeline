
variable "outputbucketid" {
	type = string
	default = ""
}

variable "ecr_url" {
  type = string
}

variable "common_tags" {
  type = map(string)
  description = "Commong tags to provision on resources created in Terraform"
  default = {
		Infra = "Lambda_Visitor_Query",
		Owner = "benwagrez@gmail.com"
  }
}
