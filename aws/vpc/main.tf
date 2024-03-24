locals {
    vpc_tags = merge(var.vpc_tags, { Name = "${var.project_name}-vpc" })
    route_table_assocations = flatten([
        for rt in var.route_tables : [for assoc in rt.route_table_assocations : {
            key =  assoc.edge == null ? "${var.project_name}-${rt.access}-${assoc.subnet_az}":"${var.project_name}-${rt.access}-${assoc.edge}" ,
            edge = assoc.edge, 
            subnet_az = assoc.subnet_az ,  
            access = rt.access
            } if assoc.edge != null || assoc.subnet_az != null 
        ] 
    ])
    
    route_tables = flatten([
        for rt in var.route_tables : [for route in rt.route_table_routes : {
            access = rt.access,
            destination = route.destination,
            target_resource = route.target_resource,
            az = route.az == null ? "" : route.az
        } 
    ]])
}

resource "aws_vpc" "this" {
    cidr_block = var.cidr_block
    tags = local.vpc_tags
}

resource "aws_subnet" "this" {
    for_each = { for subnet in var.subnets : "${subnet.access}_${subnet.az}" => {
        cidr_block = subnet.cidr_block
        az = subnet.az
        access = subnet.access
        tags = merge({ Name = "${var.project_name}-${subnet.access}-subnet-${subnet.az}", ManagedBy = "Terraform", Writer = "Cloud-Club"},subnet.tags)
    }  }
    vpc_id     = aws_vpc.this.id
    cidr_block = each.value.cidr_block
    availability_zone = "${var.region}${each.value.az}"
    tags = each.value.tags
}

# igw
resource "aws_internet_gateway" "this" {
    vpc_id = aws_vpc.this.id
    tags = {
        Name = "${var.project_name}-igw"
        ManagedBy   = "Terraform"
        Writer = "Cloud-Club"
    }
}

# nat gateway
resource "aws_eip" "this" {
    for_each = {for az in var.nat_gateway_info.az : az =>az }
    lifecycle {
        create_before_destroy = true
    }
    tags = {
        Name = "${var.project_name}-${each.value}-eip"
        ManagedBy   = "Terraform"
        Writer = "Cloud-Club"
    }
}

resource "aws_nat_gateway" "this" {
    for_each = {for az in var.nat_gateway_info.az : az =>{
        az = az,
        tags = {
            Name = "${var.project_name}-${var.nat_gateway_info.access}-${az}-ngw"
            ManagedBy   = "Terraform"
            Writer = "Cloud-Club"
        }
    } }
    allocation_id = aws_eip.this[each.key].id
    subnet_id     = aws_subnet.this["${var.nat_gateway_info.access}_${each.key}"].id
    tags = each.value.tags
    depends_on = [ aws_eip.this, aws_subnet.this ]
}

resource "aws_route_table" "this" {
    for_each = { for rt in var.route_tables : rt.access => rt }
    vpc_id = aws_vpc.this.id
    tags = {
        Name = "${var.project_name}-${each.value.access}-rt"
        ManagedBy   = "Terraform"
        Writer = "Cloud-Club"
    }
}

resource "aws_route_table_association" "this" {
    for_each = {for assoc in local.route_table_assocations : assoc.key => assoc}
    subnet_id      = each.value.subnet_az != null ? aws_subnet.this["${each.value.access}_${each.value.subnet_az}"].id : null
    gateway_id     = each.value.edge == "internet_gateway" ? aws_internet_gateway.this.id : null
    route_table_id = aws_route_table.this[each.value.access].id
}

resource "aws_route" "this" {
    for_each = { for rt in local.route_tables : "${rt.access}-${rt.az}-${rt.destination}" => rt }
    route_table_id = aws_route_table.this[each.value.access].id
    destination_cidr_block = each.value.destination
    gateway_id =  each.value.target_resource == "internet_gateway" ? aws_internet_gateway.this.id : null
    nat_gateway_id = each.value.target_resource == "nat_gateway" ? aws_nat_gateway.this[each.value.az].id : null
    # vpc_endpoint_id = each.value.target_resource == "vpc_endpoint" ? aws_vpc_endpoint.this[each.value.target_resource].id : null
}

