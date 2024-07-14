resource "google_compute_network" "this" {
  name                            = var.config.name
  auto_create_subnetworks         = false
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

resource "google_vpc_access_connector" "this" {
  count         = var.config.connector == null ? 0 : 1
  name          = "${var.config.name}-vpc-access-connector"
  ip_cidr_range = var.config.connector.ip_cidr_range
  network       = google_compute_network.this.self_link
}

resource "google_compute_router" "this" {
  name    = "${var.config.name}-router"
  network = google_compute_network.this.name
  
}

resource "google_compute_router_nat" "this" {
  name                               = "${var.config.name}-nat"
  router                             = google_compute_router.this.name
  region                             = google_compute_router.this.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  auto_network_tier="STANDARD"
}