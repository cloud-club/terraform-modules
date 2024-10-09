data "google_client_config" "this" {}


resource "google_compute_target_https_proxy" "this" {
  name             = "${var.config.name}-proxy"
  url_map          = google_compute_url_map.this.id
  certificate_map = "//certificatemanager.googleapis.com/${var.config.ssl_id}"
}

resource "google_compute_url_map" "this" {
  name            = "${var.config.name}-url-map"
  default_service = google_compute_backend_service.this.id
}

resource "google_compute_backend_service" "this" {
  name        = "${var.config.name}-backend-service"
  port_name   = "http"
  protocol    = "HTTP"
  timeout_sec = 10
  dynamic "backend" {
    for_each = var.config.backends
    content {
      description                  = lookup(backend.value, "description", null)
      group                        = "projects/${data.google_client_config.this.project}/zones/${backend.value["zone"]}/networkEndpointGroups/${backend.value["group"]}"
      balancing_mode               = backend.value["balancing_mode"]
      capacity_scaler              = backend.value["capacity_scaler"]
      max_rate_per_endpoint        = backend.value["max_rate_per_endpoint"]
    }
  }
  health_checks = [google_compute_health_check.this.id]
}

resource "google_compute_health_check" "this" {
  name               = "${var.config.name}-health-check"
  http_health_check {
    port = var.config.health_check.port
    request_path = var.config.health_check.request_path 
  }
  check_interval_sec = 5
  timeout_sec        = 5
}

resource "google_compute_global_forwarding_rule" "this" {
  name       = "${var.config.name}-forwarding-rule"
  target     = google_compute_target_https_proxy.this.id
  port_range = 443
}