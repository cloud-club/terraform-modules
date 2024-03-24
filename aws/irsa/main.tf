data "aws_caller_identity" "current" {}

resource "aws_iam_role" "this" {
  name = "${var.name}"
  managed_policy_arns = var.policy_arns

  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${var.eks_issuer_url}"
        }
        Condition = {
          StringEquals = {
            "${var.eks_issuer_url}:aud" = "sts.amazonaws.com",
            "${var.eks_issuer_url}:sub" = "system:serviceaccount:${var.service_account.namespace}:${var.service_account.name}"
          }
        }
      },
    ]
  })
  tags = {
    Name = "${var.cluster_name}-addon-external-dns-role"
  }
}