variable "config" {
  type = object({
    name           = string
    policy_arns    = optional(list(string))
    cluster_name   = string
    eks_issuer_url = string
    service_account = object({
      name      = string
      namespace = string
    })
    tags = optional(map(string))
  })
}
