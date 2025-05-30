resource "aws_lb" "this" {
  name = var.config.name
  internal = var.config.internal
  load_balancer_type = var.config.load_balancer_type
  security_groups = var.config.security_groups
  subnets = var.config.subnets
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port = var.config.port
  protocol = var.config.protocol
  default_action {
    type = var.config.default_action_type
    target_group_arn = aws_lb_target_group.this.arn
  }
  depends_on = [ aws_lb_target_group.this,aws_lb.this ]
}

resource "aws_lb_target_group" "this" {
  name = var.config.name
  port = var.config.port
  protocol = var.config.protocol
  target_type = var.config.target_type
  vpc_id = var.config.vpc_id
}

resource "aws_lb_target_group_attachment" "this" {
  for_each = { for target in var.config.target_group_attachments : target.name => target }
  target_group_arn = aws_lb_target_group.this.arn
  target_id = each.value.target_id
  port = each.value.port
  depends_on = [ aws_lb_target_group.this ]
}