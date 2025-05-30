locals {
  sqs_events = {
    health_event = {
      name        = "HealthEvent"
      description = "Karpenter interrupt - AWS health event"
      event_pattern = {
        source      = ["aws.health"]
        detail-type = ["AWS Health Event"]
      }
    }
    spot_interrupt = {
      name        = "SpotInterrupt"
      description = "Karpenter interrupt - EC2 spot instance interruption warning"
      event_pattern = {
        source      = ["aws.ec2"]
        detail-type = ["EC2 Spot Instance Interruption Warning"]
      }
    }
    instance_rebalance = {
      name        = "InstanceRebalance"
      description = "Karpenter interrupt - EC2 instance rebalance recommendation"
      event_pattern = {
        source      = ["aws.ec2"]
        detail-type = ["EC2 Instance Rebalance Recommendation"]
      }
    }
    instance_state_change = {
      name        = "InstanceStateChange"
      description = "Karpenter interrupt - EC2 instance state-change notification"
      event_pattern = {
        source      = ["aws.ec2"]
        detail-type = ["EC2 Instance State-change Notification"]
      }
    }
  }

}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/eks/${var.config.name}"
  retention_in_days = 7
}

# 클러스터 기본 설정
resource "aws_eks_cluster" "this" {
  name                      = var.config.name
  role_arn                  = var.config.eks_cluster_role_arn
  version                   = var.config.version
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }
  #클러스터 네트워크 설정
  vpc_config {
    
    security_group_ids      = [aws_security_group.eks.id]
    subnet_ids              = var.config.subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = var.config.access_cidrs
  }

  depends_on = [
    aws_cloudwatch_log_group.this,
  ]
}

resource "aws_eks_access_entry" "this" {
  for_each          = { for entry in var.config.access_entries : entry.name => entry }
  cluster_name      = aws_eks_cluster.this.name
  principal_arn     = each.value.principal_arn
  type              = each.value.type
  kubernetes_groups = each.value.kubernetes_groups
  depends_on = [
    aws_eks_cluster.this
  ]
}

# EKS Addons
data "aws_eks_addon_version" "this" {
  for_each = { for addon in var.config.addons : addon.name => addon }

  addon_name         = each.value.name
  kubernetes_version = aws_eks_cluster.this.version
  most_recent        = true
}

resource "aws_eks_addon" "this" {
  for_each = { for addon in var.config.addons : addon.name => addon }

  cluster_name = aws_eks_cluster.this.name
  addon_name   = try(each.value.name, each.key)

  addon_version               = try(each.value.version, data.aws_eks_addon_version.this[each.key].version)
  configuration_values        = each.value.config != null ? jsonencode(each.value.config) : null
  service_account_role_arn    = each.value.service_account_role_arn != null ? each.value.service_account_role_arn : null
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  depends_on = [
    aws_eks_cluster.this
  ]
}

# 클러스터 파게이트 프로필
resource "aws_eks_fargate_profile" "this" {
  cluster_name           = aws_eks_cluster.this.name
  fargate_profile_name   = "Fargate"
  pod_execution_role_arn = var.config.eks_fargate_role_arn
  subnet_ids             = var.config.subnet_ids
  selector {
    namespace = "karpenter"
  }

  selector {
    namespace = "kube-system"
    labels = {
      "k8s-app" : "kube-dns"
    }
  }

  selector {
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/name" : "aws-load-balancer-controller"
    }
  }

  lifecycle {
    ignore_changes = [
      subnet_ids
    ]
  }
  depends_on = [
    aws_eks_cluster.this
  ]
}
resource "aws_eks_pod_identity_association" "this" {
  for_each        = { for role in var.config.pod_identity_roles : role.name => role }
  cluster_name    = aws_eks_cluster.this.name
  namespace       = each.value.service_account_namespace
  service_account = each.value.service_account_name
  role_arn        = each.value.role_arn
  depends_on = [
    aws_eks_cluster.this
  ]
}

resource "aws_iam_instance_profile" "karpenter_instance_profile" {
  name = "${var.config.name}-karpenter-profile"
  role = var.config.karpenter_node_role_name
}

data "tls_certificate" "eks_oidc" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "this" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

# SQS
resource "aws_sqs_queue" "sqs_queue" {
  name                      = "${var.config.name}-karpenter-queue"
  message_retention_seconds = 300
}

data "aws_iam_policy_document" "sqs_queue_policy" {
  statement {
    sid       = "SqsWrite"
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.sqs_queue.arn]

    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
        "sqs.amazonaws.com",
      ]
    }
  }
}

resource "aws_sqs_queue_policy" "sqs_queue_policy" {
  queue_url = aws_sqs_queue.sqs_queue.url
  policy    = data.aws_iam_policy_document.sqs_queue_policy.json
}

resource "aws_cloudwatch_event_rule" "cloudwatch_event_rule" {
  for_each = { for k, v in local.sqs_events : k => v }

  name_prefix   = "Karpenter-${each.value.name}-"
  description   = each.value.description
  event_pattern = jsonencode(each.value.event_pattern)
}

resource "aws_cloudwatch_event_target" "cloudwatch_event_target" {
  for_each = { for k, v in local.sqs_events : k => v }

  rule      = aws_cloudwatch_event_rule.cloudwatch_event_rule[each.key].name
  target_id = "KarpenterInterruptionQueueTarget"
  arn       = aws_sqs_queue.sqs_queue.arn
}


# Security group
resource "aws_security_group" "eks" {
  name        = "${var.config.name}-sg"
  description = "Security group for ${var.config.name}"
  vpc_id      = var.config.vpc_id

  tags = {
    "karpenter.sh/discovery" = var.config.name
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "master_eks_ingress" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.eks.id
  security_group_id        = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

resource "aws_security_group_rule" "eks_self_ingress" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true
  security_group_id = aws_security_group.eks.id
}

resource "aws_security_group_rule" "eks_ingress" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
  security_group_id        = aws_security_group.eks.id
}

resource "aws_security_group_rule" "nginx_ingress"{
  for_each = { 30080 = "TCP", 30443 = "TCP" }
  type                     = "ingress"
  from_port                = each.key
  to_port                  = each.key
  protocol                 = each.value
  source_security_group_id = var.config.alb_security_group_id
  security_group_id        = aws_security_group.eks.id
}