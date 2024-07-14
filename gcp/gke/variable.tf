variable "config" {
  type = object({
    name     = string
    location = string
    network  = string
    subnet   = string
    master_ipv4_cidr_block     = string
    ip_allocation_policy = object({
      cluster_secondary_range_name  = string
      services_secondary_range_name = string
    })
    node_pools = list(object({
      name           = string
      node_count     = number
      node_locations = list(string)
      machine_type   = string
      disk_size_gb   = number
    }))
  })
}