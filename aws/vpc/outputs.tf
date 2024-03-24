output "vpc_id" {
    value = aws_vpc.this.id
}

output "subnets" {
    value = {for subnet in aws_subnet.this : subnet.tags.Name => subnet.id}
}