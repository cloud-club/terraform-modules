output "vpc_id" {
    value = google_compute_network.this.id
}

output "subnets" {
    value = { for k, v in google_compute_subnetwork.this : k => v.id }
}