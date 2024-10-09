resource "google_service_account" "this" {
  account_id   = "${var.config.account_id}"
}

// https://cloud.google.com/iam/docs/reference/rest/v1/Policy#Binding
resource "google_project_iam_member" "this" {
  for_each = {for role in var.config.iam_binding : role.name => role}
  project = var.project_id
  role               = each.value.role
  member = "serviceAccount:${google_service_account.this.email}" 
  depends_on = [ google_service_account.this ]
}

resource "google_service_account_iam_binding" "workflow_identity" {
  count = var.config.workflow_identity.enable ? 1 : 0
  service_account_id = google_service_account.this.name
  role               = "roles/iam.workloadIdentityUser"
  members = ["serviceAccount:${var.project_id}.svc.id.goog[${var.config.workflow_identity.namespace}/${var.config.workflow_identity.service_account}]"]
  depends_on = [ google_service_account.this ]
}
