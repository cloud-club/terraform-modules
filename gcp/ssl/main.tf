resource "google_compute_managed_ssl_certificate" "this" {
  name = "${var.config.name}"
  managed {
    domains = var.config.domains
  }
}