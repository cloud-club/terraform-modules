locals {
  plain_parameters = {
    for param in var.config : param.name => param if param.type == "String"
  }
  secret_parameters = {
    for param in var.config : param.name => param if param.type == "SecureString"
  }
}


resource "aws_ssm_parameter" "plain" {
  for_each    = local.plain_parameters
  name        = each.key
  description = each.value.description
  type        = "String"
  value       = each.value.data
}

resource "aws_ssm_parameter" "secret" {
  for_each    = local.secret_parameters
  name        = each.key
  description = each.value.description
  type        = "SecureString"
  value       = rsadecrypt(each.value.data, file(var.private_key_path))
  key_id      = each.value.key_id
}