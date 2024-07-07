data "aws_caller_identity" "current" {}

resource "aws_iam_role" "this" {
  name                = var.config.name
  managed_policy_arns = var.config.policy_arns

  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${var.config.eks_issuer_url}"
        }
        Condition = {
          StringEquals = {
            "${var.config.eks_issuer_url}:aud" = "sts.amazonaws.com",
            "${var.config.eks_issuer_url}:sub" = "system:serviceaccount:${var.config.service_account.namespace}:${var.config.service_account.name}"
          }
        }
      },
    ]
  })
  tags = var.config.tags
}
