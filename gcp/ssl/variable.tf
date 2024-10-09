variable "config" {
  type = object({
    name    = string
    managed_zone = string
    dns_authorizations = list(object({
      name        = string
      domain      = string
      use_wildcard = optional(bool,false)
    }))
  })
}