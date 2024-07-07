resource "aws_ssm_parameter" "this" {
  name        = var.config.name
  description = var.config.description
  type        = "String"
  value       = var.config.value
}
