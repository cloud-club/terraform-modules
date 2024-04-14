output "eks" {
  value = aws_eks_cluster.this.arn
}

output "eks_name" {
  value = aws_eks_cluster.this.name
}

output "eks_endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "eks_identity" {
  value = aws_eks_cluster.this.identity
}
