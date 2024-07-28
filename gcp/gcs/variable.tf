variable "config" {
  type = object({
    name = string
    location = string
    class = optional(string, "STANDARD")
    website = optional(object({
      main = string
      not_found = string
    }),null)
    cors = optional(object({
      origin = list(string)
      method = list(string)
      response_header = list(string)
    }),null)
    iam = optional(list(object({
        name = string
        role = string
        member = string
        condition = optional(object({
            title = string
            description = string
            expression = string
        }),null)
    })),[])
  })
}