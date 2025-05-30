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

output "eks_oidc_issuer" {
  value = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

output "eks_oidc_arn" {
  value = aws_iam_openid_connect_provider.this.arn
}