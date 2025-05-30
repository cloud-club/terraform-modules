variable "config" {
  type = object({
    name           = string
    eks_oidc_arn   = string
    eks_oidc_issuer = string
    policy_arns    = optional(list(string),[])
    service_account = object({
      name      = string
      namespace = string
    })
    inline_policies = optional(list(object({
      name = string
      policy_file = string
    })), [])
    tags = optional(map(string))
  })
}
