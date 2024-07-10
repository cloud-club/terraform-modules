resource "google_compute_network" "this" {
  name                            = var.config.name
  auto_create_subnetworks         = false
  delete_default_routes_on_create = true
  routing_mode                    = var.config.routing_mode == null ? "REGIONAL" : var.config.routing_mode
}

resource "google_compute_subnetwork" "this" {
  for_each      = { for subnet in var.config.subnets : subnet.name => subnet }
  name          = each.value.name
  ip_cidr_range = each.value.ip_cidr_range
  region        = each.value.region
  network       = google_compute_network.this.id
  private_ip_google_access = true
  dynamic "secondary_ip_range" {
    for_each = each.value.secondary_ip_ranges == null ? [] : each.value.secondary_ip_ranges
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }
}
