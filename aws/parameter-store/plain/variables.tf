variable "config" {
  type = object({
    name        = string
    description = optional(string)
    value       = string
  })
}
