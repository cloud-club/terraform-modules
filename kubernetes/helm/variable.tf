variable "config" {
  type = list(object({
    name       = string
    namespace  = string
    repository = string
    chart      = string
    version    = string
    file = optional(object({
      path    = string
      vars    = map(string)
      secrets = map(string)
    }))
    set_values = optional(map(string), {})
  }))
}

variable "encrypt_file_path" {
  type = string
}