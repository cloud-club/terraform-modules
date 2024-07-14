variable "config" {
  type = object({
    name    = string
    domains = list(string)
  })
}