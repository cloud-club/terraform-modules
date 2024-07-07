resource "aws_ssm_parameter" "this" {
  name        = var.config.name
  description = var.config.description
  type        = "SecureString"
  value       = rsadecrypt(var.config.value, file(var.config.private_key_path))
  key_id      = var.config.key_id
}
