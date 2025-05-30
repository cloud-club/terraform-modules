data "aws_caller_identity" "current" {}


data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect = "Allow"
    principals {
      type = "Federated"
      identifiers = [var.config.eks_oidc_arn]
    }
    condition {
      test = "StringEquals"
      variable = "${var.config.eks_oidc_issuer}:sub"
      values = ["system:serviceaccount:${var.config.service_account.namespace}:${var.config.service_account.name}"]
    }
    condition {
      test = "StringEquals"
      variable = "${var.config.eks_oidc_issuer}:aud"
      values = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name                = var.config.name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags = var.config.tags
}

resource "aws_iam_role_policy_attachment" "managed_policy" {
  for_each = { for policy in var.config.policy_arns : policy => policy }
  role = aws_iam_role.this.name
  policy_arn = each.value
}

resource "aws_iam_policy" "custom_policy" {
    for_each = {for policy in var.config.inline_policies : policy.name => policy}
    name = each.value.name
    policy = file("${each.value.policy_file}")
}

resource "aws_iam_role_policy_attachment" "custom_policy" {
    for_each = {for policy in var.config.inline_policies : policy.name => policy}
    role = aws_iam_role.this.name
    policy_arn = aws_iam_policy.custom_policy[each.value.name].arn
}