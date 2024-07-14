resource "google_compute_firewall" "this" {
  name               = var.config.name
  network            = var.config.network
  direction          = var.config.direction
  disabled           = var.config.disabled
  source_ranges      = var.config.direction == "INGRESS" ? var.config.ranges : null
  destination_ranges = var.config.direction == "EGRESS" ? var.config.ranges : null

  dynamic "allow" {
    for_each = lookup(var.config, "allow", [])
    content {
      protocol = allow.value.protocol
      ports    = lookup(allow.value, "ports", null)
    }
  }

  dynamic "deny" {
    for_each = lookup(var.config, "deny", [])
    content {
      protocol = deny.value.protocol
      ports    = lookup(deny.value, "ports", null)
    }
  }
}