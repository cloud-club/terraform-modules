resource "aws_iam_role" "this" {
    name               = var.config.name
    assume_role_policy = file("${var.config.assume_role_policy_file}")
}

resource "aws_iam_role_policy_attachment" "managed_policy" {
    for_each = {for policy in var.config.policy_arns : policy => policy}
    policy_arn = each.value
    role       = aws_iam_role.this.name
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