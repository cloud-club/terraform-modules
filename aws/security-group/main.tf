locals {
  ingress_cidr_blocks = { for k, r in var.config.ingress_rules : k => r if length(coalesce(r.cidr_blocks, [])) > 0 }
  egress_cidr_blocks  = { for k, r in var.config.egress_rules : k => r if length(coalesce(r.cidr_blocks, [])) > 0 }

  ingress_self_rules = { for k, r in var.config.ingress_rules : k => r if r.self == true }
  egress_self_rules  = { for k, r in var.config.egress_rules : k => r if r.self == true }

  ingress_source_security_group_ids = { for k, r in var.config.ingress_rules : k => r if r.security_group_id != null }
  egress_source_security_group_ids  = { for k, r in var.config.egress_rules : k => r if r.security_group_id != null }
}

resource "aws_security_group" "this" {
  name   = var.config.name
  vpc_id = var.config.vpc_id
  tags   = var.config.tags
}

resource "aws_security_group_rule" "ingress" {
  for_each          = local.ingress_cidr_blocks
  security_group_id = aws_security_group.this.id
  type              = "ingress"
  from_port         = each.value.ingress_from_port
  to_port           = each.value.ingress_to_port
  protocol          = each.value.ingress_protocol
  cidr_blocks       = each.value.cidr_blocks
  depends_on        = [aws_security_group.this]
}

resource "aws_security_group_rule" "self_ingress" {
  for_each          = local.ingress_self_rules
  security_group_id = aws_security_group.this.id
  type              = "ingress"
  from_port         = each.value.ingress_from_port
  to_port           = each.value.ingress_to_port
  protocol          = each.value.ingress_protocol
  self              = true
  depends_on        = [aws_security_group.this]
}

resource "aws_security_group_rule" "ingress_source_security_group_ids" {
  for_each                 = local.ingress_source_security_group_ids
  security_group_id        = aws_security_group.this.id
  type                     = "ingress"
  from_port                = each.value.ingress_from_port
  to_port                  = each.value.ingress_to_port
  protocol                 = each.value.ingress_protocol
  source_security_group_id = each.value.security_group_id
  depends_on               = [aws_security_group.this]
}

resource "aws_security_group_rule" "egress" {
  for_each          = local.egress_cidr_blocks
  security_group_id = aws_security_group.this.id
  type              = "egress"
  from_port         = each.value.egress_from_port
  to_port           = each.value.egress_to_port
  protocol          = each.value.egress_protocol
  cidr_blocks       = each.value.cidr_blocks
  depends_on        = [aws_security_group.this]
}

resource "aws_security_group_rule" "self_egress" {
  for_each          = local.egress_self_rules
  security_group_id = aws_security_group.this.id
  type              = "egress"
  from_port         = each.value.egress_from_port
  to_port           = each.value.egress_to_port
  protocol          = each.value.egress_protocol
  self              = true
  depends_on        = [aws_security_group.this]
}

resource "aws_security_group_rule" "egress_source_security_group_ids" {
  for_each                 = local.egress_source_security_group_ids
  security_group_id        = aws_security_group.this.id
  type                     = "egress"
  from_port                = each.value.egress_from_port
  to_port                  = each.value.egress_to_port
  protocol                 = each.value.egress_protocol
  source_security_group_id = each.value.security_group_id
  depends_on               = [aws_security_group.this]
}
