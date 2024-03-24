resource "aws_instance" "this" {
    subnet_id = var.subnet_id
    ami = var.ami
    instance_type = var.instance_type
    iam_instance_profile = var.create_instance_profile ? aws_iam_instance_profile.this[0].name : var.profile_name
    root_block_device {
        volume_size = var.root_volume_size
        iops = 3000
        throughput = 125
        volume_type = "gp3"
    }
    security_groups = var.security_groups
    user_data = var.user_data != "" ? var.user_data : null
    tags = {
        Name = var.name
    }
    depends_on = [ aws_iam_instance_profile.this]
}

resource "aws_iam_instance_profile" "this" {
    count = var.create_instance_profile ? 1 : 0
    name = "${var.role_name}-profile"
    role = var.create_iam_role ? aws_iam_role.this[0].name : var.role_name
    depends_on = [ aws_iam_role.this ]
}

resource "aws_iam_role" "this" {
    count = var.create_iam_role ? 1 : 0
    name = var.role_name == "" ? "${var.name}-ec2-role" : var.role_name
    managed_policy_arns = var.policy_arns
    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Action = "sts:AssumeRole",
                Effect = "Allow",
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore" {
    count = var.attach_ssm_role ? 1 : 0
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    role = aws_iam_role.this[0].name
    depends_on = [ aws_iam_role.this ]
}