resource "google_storage_bucket" "this" {
  name = var.config.name
  location = var.config.location
  storage_class = var.config.class
  dynamic "website" {
    for_each = var.config.website != null ? [var.config.website] : []
    content {
      main_page_suffix = website.value.main
      not_found_page = website.value.not_found
    }
  }

  dynamic "cors" {
    for_each = var.config.cors != null ? [var.config.cors] : []
    content {
      origin = cors.value.origin
      method = cors.value.method
      response_header = cors.value.response_header
      max_age_seconds = 3600
    }
  }
}

resource "google_storage_bucket_iam_member" "this" {
  for_each = { for iam in var.config.iam : iam.name => iam }
  bucket = google_storage_bucket.this.name
  role = each.value.role
  member = each.value.member
  dynamic "condition" {
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      title = condition.value.title
      description = condition.value.description
      expression = condition.value.expression
    }
  }
}