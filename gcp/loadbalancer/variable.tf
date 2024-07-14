variable "config" {
  type = object({
    name = string
    ssl_id = string
    backends = list(object({
      group                        = string
      zone                         = string
      balancing_mode               = optional(string,"RATE")
      capacity_scaler              = optional(number,1)
      max_rate_per_endpoint        = optional(number,10)
    }))
    health_check = object({
      port      = optional(number, 80)
      port_name = optional(string, null)
      request_path = optional(string, "/")
    })
  })
}