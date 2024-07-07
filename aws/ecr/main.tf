data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}


locals {
  encryption_configuration_list = var.config.encryption_configuration != null ? [var.config.encryption_configuration] : []
}

resource "aws_ecr_repository" "this" {
  name                 = var.config.name
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = var.config.scan_on_push != null ? var.config.scan_on_push : false
  }
  dynamic "encryption_configuration" {
    for_each = { for v in local.encryption_configuration_list : v.encryption_type => v }
    content {
      encryption_type = encryption_configuration.value.encryption_type
      kms_key         = encryption_configuration.value.kms_arn
    }
  }
  tags = var.config.tags
}

output "ecr" {
  value = aws_ecr_repository.this
}


resource "aws_ecr_repository_policy" "this" {
  count      = var.config.policy_path != null ? 1 : 0
  repository = aws_ecr_repository.this.name
  policy     = file(var.config.policy_path)
}
