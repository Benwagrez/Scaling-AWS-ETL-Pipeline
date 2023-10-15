resource "aws_ssm_parameter" "GitConnectionString" {
  for_each   = {
    for index, client in var.prod_clients:
    client.Name => client
  }

  name     = "/git/${each.value.Name}"
  type     = "String"
  value    = each.value.GitConnectionString
}
