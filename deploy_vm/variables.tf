variable "common_tags" {
  type = map(string)
  description = "Commong tags to provision on resources created in Terraform"
  default = {
      Infra = "deploy_vm",
      Owner = "benwagrez@gmail.com"
  }
}

variable "CallerID" {
  type = string
}

variable "sshpublickey" {
  type = string
}

variable "DataOutputBucketName"{
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