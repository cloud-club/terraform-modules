data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

locals {
  policy_file = file("${var.policy_path}")
}

resource "aws_ecr_repository" "this" {
  name                 = var.repositry_name
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }
  dynamic "encryption_configuration" {
    for_each = var.encryption_configuration
    content {
      encryption_type = encryption_configuration.value.encryption_type
      kms_key          = encryption_configuration.value.kms_key
    }
  }
  
  tags = {
    Name        = var.tags.name
    Environment = var.tags.environment
    ManagedBy   = "Terraform"
  }
}
output "ecr" {
  value = aws_ecr_repository.this
}


resource "aws_ecr_repository_policy" "this" {
  repository = aws_ecr_repository.this.name
  policy     = local.policy_file
}
