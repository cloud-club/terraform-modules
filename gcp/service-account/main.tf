resource "google_service_account" "this" {
  account_id   = "${var.config.account_id}"
}

// https://cloud.google.com/iam/docs/reference/rest/v1/Policy#Binding
resource "google_service_account_iam_binding" "this" {
  for_each = {for role in var.config.iam_binding : role.name => role}
  service_account_id = google_service_account.this.name
  role               = each.value.role
  members = each.value.members
  depends_on = [ google_service_account.this ]
}

resource "google_service_account_iam_binding" "workflow_identity" {
  count = var.config.is_workload_identity ? 1 : 0
  service_account_id = google_service_account.this.name
  role               = "roles/iam.workloadIdentityUser"
  members = ["serviceAccount:${google_service_account.this.email}" ]
  depends_on = [ google_service_account.this ]
}