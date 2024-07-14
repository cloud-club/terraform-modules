output "name" {
    value = google_compute_network.this.name
}

output "subnets" {
    value = { for k, v in google_compute_subnetwork.this : k => v.id }
}