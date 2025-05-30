variable "config" {
  type = object({
    name       = string
    cidr_block = string
    region     = string
    nat_gateway_info = optional(object({
      access = string
      az     = list(string)
    }))
    tags = optional(map(string))
    subnets = list(object({
      cidr_block = string
      az         = string
      access     = string
      tags       = optional(map(string),{})
    }))
    route_tables = list(object({
      access = string
      route_table_assocations = optional(list(object({
        edge      = optional(string)
        subnet_az = optional(string)
      })))
      route_table_routes = optional(list(object({
        destination     = string
        target_resource = string
        az              = optional(string)
      })))
    }))
  })
}

# variable "subnets" {
#   type = list(object({
#     cidr_block = string
#     az = string
#     access = string
#     tags = optional(map(string))
#   }))
#     default = [
#         {
#             az = "a"
#             access = "public"
#             cidr_block = "10.0.100.0/24"
#         },
#         {
#             az = "b"
#             access = "public"
#             cidr_block = "10.0.101.0/24"
#         },
#         {
#             az = "c"
#             access = "public"
#             cidr_block = "10.0.102.0/24"
#         },
#         {
#             az = "a"
#             access = "private"
#             cidr_block = "10.0.0.0/24"
#         },
#         {
#             az = "b"
#             access = "private"
#             cidr_block = "10.0.1.0/24"
#         },
#         {
#             az = "c"
#             access = "private"
#             cidr_block = "10.0.2.0/24"
#         }
#     ]
# }

# variable "route_tables" {
#     type = list(object({
#     access = string
#     route_table_assocations = optional(list(object({
#         edge = optional(string)
#         subnet_az = optional(string)
#     })))
#     route_table_routes = optional(list(object({
#         # name = string
#         destination = string
#         target_resource = string
#         az = optional(string)
#         })))
#     }))
#     default = [
#         {
#             access = "public"
#             route_table_assocations = [   
#                 {
#                     subnet_az = "a"
#                 },
#                 {
#                     subnet_az = "b"
#                 },
#                 {
#                     subnet_az = "c"
#                 }
#             ]
#             route_table_routes = [
#                 {
#                     destination = "0.0.0.0/0"
#                     target_resource = "internet_gateway"
#                 }
#             ]
#         },
#         {
#             access = "private"
#             route_table_assocations = [   
#                 {
#                     subnet_az = "a"
#                 },
#                 {
#                     subnet_az = "b"
#                 },
#                 {
#                     subnet_az = "c"
#                 }
#             ]
#             route_table_routes = [
#                 {
#                     destination = "0.0.0.0/0"
#                     target_resource = "nat_gateway"
#                     az = "a"
#                 }
#             ]
#         }
#     ]
# }