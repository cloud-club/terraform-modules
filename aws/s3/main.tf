resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  tags = {
    Name        = var.bucket_name
    ManagedBy   = "Terraform"
    Writer = "Cloud-Club"
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
    bucket = aws_s3_bucket.this.id
    block_public_acls       = var.public_access_block
    block_public_policy     = var.public_access_block
    ignore_public_acls      = var.public_access_block
    restrict_public_buckets = var.public_access_block    
    depends_on = [ aws_s3_bucket.this ]
}

resource "aws_s3_bucket_versioning" "this" {
    count = var.enable_versioning ? 1 : 0
    bucket = aws_s3_bucket.this.id
    versioning_configuration {
        status = "Enabled"
    }
    depends_on = [ aws_s3_bucket.this ]
}

resource "aws_s3_bucket_cors_configuration" "this" {
  bucket = aws_s3_bucket.this.id
  dynamic "cors_rule" {
    for_each = var.cors_policy
    content {
      allowed_headers = cors_rule.value.allowed_headers
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      expose_headers  = cors_rule.value.expose_headers
    }
  }
  depends_on = [ aws_s3_bucket.this ]
}

resource "aws_s3_bucket_policy" "this"{
    count = length(var.s3_policy_statements) > 0 ? 1 : 0
    bucket = aws_s3_bucket.this.id
    policy = data.aws_iam_policy_document.this.json
    depends_on = [ aws_s3_bucket.this ]
}

data "aws_iam_policy_document" "this" {
  dynamic "statement" {
      for_each = var.s3_policy_statements
      content {
          actions = statement.value.actions
          resources = statement.value.resources
          effect = statement.value.effect
        
        dynamic "principals" {
          for_each = lookup(statement.value, "principals", [])
          content {
            type = principals.value.type
            identifiers = principals.value.identifiers
          }
        }
        dynamic "condition" {
          for_each = lookup(statement.value, "condition", [])
          content {
            test     = condition.value.test
            variable = condition.value.variable
            values   = condition.value.values
          }
        }
      }
  }
}

