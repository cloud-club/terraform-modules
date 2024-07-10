variable "config" {
  type = object({
    name = string
    routing_mode = optional(string)
    subnets = list(object({
      name          = string
      region        = string
      ip_cidr_range = string
      secondary_ip_ranges = optional(list(object({
        range_name    = string
        ip_cidr_range = string
      })))
    }))
  })
}