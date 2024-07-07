data "tls_certificate" "eks_oidc" {
  url = var.issuer_url
}

resource "aws_iam_openid_connect_provider" "this" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint]
  url             = var.issuer_url
  depends_on      = [data.tls_certificate.eks_oidc]
}
