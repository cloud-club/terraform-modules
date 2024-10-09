locals {
  wildcard_domains = [for dns in var.config.dns_authorizations: "*.${dns.domain}" if dns.use_wildcard]
}


resource "google_certificate_manager_dns_authorization" "this" {
  for_each = { for dns in var.config.dns_authorizations : dns.name => dns }
  name        = each.value.name
  description = "DNS authorization for ${each.value.domain}"
  domain      = each.value.domain
}

resource "google_dns_record_set" "this" {
  for_each = { for dns in var.config.dns_authorizations : dns.name => dns }
  name         = google_certificate_manager_dns_authorization.this["${each.value.name}"].dns_resource_record.0.name
  type         = google_certificate_manager_dns_authorization.this["${each.value.name}"].dns_resource_record.0.type
  ttl          = 30
  managed_zone = var.config.managed_zone
  rrdatas      = [google_certificate_manager_dns_authorization.this["${each.value.name}"].dns_resource_record.0.data]
  depends_on = [ google_certificate_manager_dns_authorization.this ]
}

resource "google_certificate_manager_certificate" "this" {
  name        = "${var.config.name}-certificate"
  description = "Managed certificate for ${var.config.name}"
  scope       = "DEFAULT"
  managed {
    domains = concat([for d in google_certificate_manager_dns_authorization.this : d.domain],local.wildcard_domains)
    dns_authorizations = [for d in google_certificate_manager_dns_authorization.this : d.id]
  }
  depends_on = [ google_dns_record_set.this ]
}

resource "google_certificate_manager_certificate_map" "this" {
  name    = "${var.config.name}-certificate-map"
}

resource "google_certificate_manager_certificate_map_entry" "this" {
  name         = "${var.config.name}-certificate-map-entry"
  map          = google_certificate_manager_certificate_map.this.name
  matcher      = "PRIMARY"
  certificates = [google_certificate_manager_certificate.this.id]
  depends_on = [ google_certificate_manager_certificate.this, google_certificate_manager_certificate_map.this ]
}