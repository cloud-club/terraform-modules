variable "cluster_name" {
    description = "EKS 클러스터 이름"
    type        = string
}

variable "k8s_cluster_version" {
    description = "EKS 클러스터 버전"
    type        = string
}


variable "public_access_cidrs" {
    description = "EKS 클러스터 퍼블릭 엑세스 CIDR"
    type        = list(string)
    default = [  ]
}


variable "security_group_ids" {
    description = "EKS cluster vpc security config"
    type = list(string)
    default = [  ]
}

variable "private_subnets" {
    description = "EKS cluster vpc private subnets"
    type = list(string)
    default = [  ]
}

variable "node_specs" {
    description = "node group specs for eks cluster"
    type = list(object({
        name = string
        instance_types = list(string)
        volume_size = number
        desired_size = number
        min_size = number
        max_size = number
    }))
    default = [
        {
            name = "t3.large"
            instance_types = ["t3.large"]
            volume_size = 50
            desired_size = 3
            min_size = 3
            max_size = 3
        }
    ]
}

variable "eks_cluster_role_policys" {
    description = "eks cluster role policy arns"
    type = list(object({
        name= string
        arn = string
    }))
    default = [
        {
            name = "AmazonEKSClusterPolicy"
            arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
        },
        {
            name = "AmazonEKSVPCResourceController"
            arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
        }
    ]
}

variable "node_role_policys" {
    description = "node role policy arns"
    type = list(object({
        name= string
        arn = string
    }))
    default = [
        {
            name = "AmazonEKSWorkerNodePolicy"
            arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
        },
        {
            name = "AmazonSSMManagedInstanceCore"
            arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
        },
        {
            name = "AmazonEKS_CNI_Policy"
            arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
        },
        {
            name = "AmazonEC2ContainerRegistryReadOnly"
            arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
        }
    ]
}


variable "addons" {
  type = list(object({
    name = string
    version = optional(string)
  }))
    default = [
        {
        name = "kube-proxy"
        },
        {
        name = "vpc-cni"
        },
        {
        name = "coredns"
        },
        {
        name = "aws-ebs-csi-driver"
        }
    ]
}