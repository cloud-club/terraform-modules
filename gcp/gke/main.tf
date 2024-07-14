data "google_client_config" "this" {}

resource "google_service_account" "this" {
  account_id   = "service-account-id"
  display_name = "Service Account"
}

resource "google_container_cluster" "this" {
  name       = var.config.name
  location   = var.config.location
  network    = var.config.network
  subnetwork = var.config.subnet
  remove_default_node_pool = true
  enable_shielded_nodes    = "true"
  initial_node_count       = 1
  networking_mode          = "VPC_NATIVE"
  deletion_protection = false
  ip_allocation_policy {
    cluster_secondary_range_name  = var.config.ip_allocation_policy.cluster_secondary_range_name
    services_secondary_range_name = var.config.ip_allocation_policy.services_secondary_range_name
  }
  private_cluster_config {
    enable_private_nodes = true
    enable_private_endpoint = false
    master_ipv4_cidr_block     = var.config.master_ipv4_cidr_block
  }
  gateway_api_config {
    channel = "CHANNEL_STANDARD"
  }
    
  release_channel {
    channel = "STABLE"
  }
  addons_config {
    http_load_balancing {
      disabled = false
    }
    dns_cache_config {
      enabled = true
    }
    gce_persistent_disk_csi_driver_config {
      enabled = true
    }
  }
  
  workload_identity_config {
    workload_pool = "${data.google_client_config.this.project}.svc.id.goog"
  }

}

resource "google_container_node_pool" "this" {
  for_each   = { for node_pool in var.config.node_pools : node_pool.name => node_pool }
  name       = each.value.name
  cluster    = google_container_cluster.this.name
  node_count = each.value.node_count

  node_locations = each.value.node_locations
  
  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    preemptible  = false
    machine_type = each.value.machine_type
    spot         = true
    disk_size_gb = each.value.disk_size_gb
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.this.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/devstorage.read_only",
    ]
    tags = ["ssh"]
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }
}