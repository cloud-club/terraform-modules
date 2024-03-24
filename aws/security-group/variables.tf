variable "security_group_name" {
    type = string
    description = "The name of the security group"
    default = "demo"
}

variable "vpc_id" {
    type = string
    description = "The VPC ID"
    default = ""
}

variable "project_name" {
    type = string
    description = "The name of the project"
    default = "cloud-club"
}

variable "ingress_rules" {
  type = map(object({
    ingress_from_port = number
    ingress_to_port = number
    ingress_protocol = string
    self = optional(bool)
    cidr_blocks = optional(list(string))
    security_group_id = optional(string)
  }))
    description = "The ingress rules"
    default = {
        http = {
            ingress_from_port = 80
            ingress_to_port = 80
            ingress_protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
        https = {
            ingress_from_port = 443
            ingress_to_port = 443
            ingress_protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
        # ssh = {
        #     ingress_from_port = 22
        #     ingress_to_port = 22
        #     ingress_protocol = "tcp"
        #     security_group_id = "sg-123123123"
        # }
        self_custom = {
            ingress_from_port = 0
            ingress_to_port = 0
            ingress_protocol = "-1"
            self = true
        }
    }
}


variable "egress_rules" {
  type = map(object({
    egress_from_port = number
    egress_to_port = number
    egress_protocol = string
    self = optional(bool)
    cidr_blocks = optional(list(string))
    security_group_id = optional(string)
  }))
    description = "The egress rules"
    default = {
        all = {
            egress_from_port = 0
            egress_to_port = 0
            egress_protocol = "-1"
        }
    }
}