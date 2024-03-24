

variable "cidr_block" {
  type = string
  default = "10.0.0.0/16"
}

variable "project_name" {
  type = string
    default = "demo"
}

variable "region" {
    type = string
    default = "ap-northeast-2"
}


variable "nat_gateway_info" {
    type = object({
        access = string
        az = list(string)
        }
    )
    default ={
        access = "public"
        az = ["a"]
    }
}

variable "vpc_tags" {
    type = map(string)
    default = {
        Name        = "vpc"
        Environment = "dev"
        ManagedBy   = "Terraform"
    }
}


variable "subnets" {
  type = list(object({
    cidr_block = string
    az = string
    access = string
    tags = optional(map(string))
  }))
    default = [
        {
            az = "a"
            access = "public"
            cidr_block = "10.0.100.0/24"
        },
        {
            az = "b"
            access = "public"
            cidr_block = "10.0.101.0/24"
        },
        {
            az = "c"
            access = "public"
            cidr_block = "10.0.102.0/24"
        },
        {
            az = "a"
            access = "private"
            cidr_block = "10.0.0.0/24"
        },
        {
            az = "b"
            access = "private"
            cidr_block = "10.0.1.0/24"
        },
        {
            az = "c"
            access = "private"
            cidr_block = "10.0.2.0/24"
        }
    ]
}

variable "route_tables" {
    type = list(object({
    access = string
    route_table_assocations = optional(list(object({
        edge = optional(string)
        subnet_az = optional(string)
    })))
    route_table_routes = optional(list(object({
        # name = string
        destination = string
        target_resource = string
        az = optional(string)
        })))
    }))
    default = [
        {
            access = "public"
            route_table_assocations = [   
                {
                    subnet_az = "a"
                },
                {
                    subnet_az = "b"
                },
                {
                    subnet_az = "c"
                }
            ]
            route_table_routes = [
                {
                    destination = "0.0.0.0/0"
                    target_resource = "internet_gateway"
                }
            ]
        },
        {
            access = "private"
            route_table_assocations = [   
                {
                    subnet_az = "a"
                },
                {
                    subnet_az = "b"
                },
                {
                    subnet_az = "c"
                }
            ]
            route_table_routes = [
                {
                    destination = "0.0.0.0/0"
                    target_resource = "nat_gateway"
                    az = "a"
                }
            ]
        }
    ]
}