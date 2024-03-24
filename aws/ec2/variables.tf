variable "subnet_id" {
  type = string
  description = "The subnet ID to launch the instance in"
  default = ""
}

variable "ami" {
  type = string
  description = "The AMI to use for the instance"
  default = ""
}

variable "instance_type" {
  type = string
  description = "The instance type to use for the instance"
  default = "t2.micro"
}

variable "root_volume_size" {
  type = number
  description = "The size of the root volume in GB"
  default = 20
}

variable "security_groups" {
  type = list(string)
  description = "The security groups to associate with the instance"
  default = []
}

variable "name" {
  type = string
  description = "The name of the instance"
  default = ""
}

variable "user_data" {
  type = string
  description = "The user data to use for the instance"
  default = ""
}

variable "role_name" {
  type = string
  description = "The name of the IAM role to create"
  default = ""
}

variable "policy_arns" {
  type = list(string)
  description = "The ARNs of the managed policies to attach to the IAM role"
  default = []
}


variable "create_instance_profile" {
  type = bool
  description = "Whether to create an instance profile for the instance"
  default = true
}

variable "profile_name" {
  type = string
  description = "The name of the instance profile to use for the instance"
  default = ""
}

variable "create_iam_role" {
  type = bool
  description = "Whether to create an IAM role for the instance"
  default = true
}

variable "attach_ssm_role" {
  type = bool
  description = "Whether to attach the AmazonSSMManagedInstanceCore policy to the IAM role"
  default = true
}