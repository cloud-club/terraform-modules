resource "aws_cloudwatch_log_group" "this" {
    name              = "/aws/eks/${var.cluster_name}/cluster"
    retention_in_days = 7
}

# 클러스터 기본 설정
resource "aws_eks_cluster" "this" {
    name                      = var.cluster_name
    role_arn                  = aws_iam_role.this.arn
    version                   = var.k8s_cluster_version
    enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

    #클러스터 네트워크 설정
    vpc_config {
        security_group_ids      = var.security_group_ids
        subnet_ids              = module.vpc.private_subnets
        endpoint_private_access = true
        endpoint_public_access  = true
        public_access_cidrs     = var.public_access_cidrs
    }

    depends_on = [
        aws_iam_role_policy_attachment.eks,
        aws_cloudwatch_log_group.this,
        module.vpc
    ]
}

resource "aws_eks_addon" "addons" {
    for_each     = { for addon in var.addons : addon.name => addon }
    cluster_name = aws_eks_cluster.this.name
    addon_name   = each.value.name

    resolve_conflicts_on_create = "OVERWRITE"
    resolve_conflicts_on_update = "PRESERVE"
    depends_on = [
        aws_eks_cluster.this,
        aws_eks_node_group.this
    ]
}

resource "aws_iam_role" "eks" {
    name = var.cluster_name
    assume_role_policy = data.aws_iam_policy_document.eks.json
}

data "aws_iam_policy_document" "eks" {
    statement {
        actions = ["sts:AssumeRole"]
        effect  = "Allow"
        principals {
            type        = "Service"
            identifiers = ["eks.amazonaws.com"]
        }
    }
}

resource "aws_iam_role_policy_attachment" "eks" {
    for_each = { for policy in var.eks_cluster_role_policys : policy.name => policy }
    policy_arn = each.value.arn
    role       = aws_iam_role.eks.name
}

resource "aws_iam_role" "node" {
    name = "${var.cluster_name}-node"
    assume_role_policy = data.aws_iam_policy_document.node.json
}

data "aws_iam_policy_document" "node" {
    statement {
        actions = ["sts:AssumeRole"]
        effect  = "Allow"
        principals {
            type        = "Service"
            identifiers = ["ec2.amazonaws.com"]
        }
    }
}

resource "aws_iam_role_policy_attachment" "node" {
    for_each = { for policy in var.node_role_policys : policy => policy }
    policy_arn = each.value.arn
    role       = aws_iam_role.node.name
}

resource "aws_autoscaling_group_tag" "this" {
    for_each = { for spec in var.node_specs : spec.name => spec }
    autoscaling_group_name = aws_eks_node_group.this[each.value.name].resources[0].autoscaling_groups[0].name
    tag {
        key                 = "Name"
        value               = "${var.cluster_name}-node"
        propagate_at_launch = true
    }
}

resource "aws_eks_node_group" "this" {
    for_each = { for spec in var.node_specs : spec.name => spec }
    cluster_name    = var.cluster_name
    node_group_name = "${var.cluster_name}-node"
    node_role_arn   = aws_iam_role.node.arn
    subnet_ids      = var.private_subnets
    instance_types  = each.value.instance_types
    disk_size       = each.value.volume_size

    labels = {
        "role" = "${var.cluster_name}-node"
    }

    scaling_config {
        desired_size = each.value.desired_size
        min_size     =  each.value.min_size
        max_size     =  each.value.max_size
    }

    depends_on = [
        aws_iam_role_policy_attachment.node,
        aws_eks_cluster.this
    ]

    tags = {
        "Name"  = "${var.cluster_name}-node",
        "Names" = "${var.cluster_name}-node"
    }
}