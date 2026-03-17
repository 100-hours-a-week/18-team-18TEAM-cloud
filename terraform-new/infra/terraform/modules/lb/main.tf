resource "aws_lb" "this" {
  name               = var.name
  internal           = var.internal
  load_balancer_type = var.load_balancer_type
  subnets            = var.subnet_ids
  security_groups    = var.load_balancer_type == "application" ? var.security_group_ids : null

  tags = merge(var.tags, {
    Name = var.name
  })
}

resource "aws_lb_target_group" "this" {
  name        = substr("${var.name}-tg", 0, 32)
  port        = var.target_port
  protocol    = var.target_group_protocol
  target_type = var.target_type
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    protocol            = var.health_check_protocol
    path                = var.health_check_path
    port                = var.health_check_port
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 30
    timeout             = 6
  }

  tags = merge(var.tags, {
    Name = "${var.name}-tg"
  })
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.listener_port
  protocol          = var.listener_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_lb_target_group_attachment" "this" {
  for_each = {
    for idx, id in var.target_instance_ids : idx => id
  }

  target_group_arn = aws_lb_target_group.this.arn
  target_id        = each.value
  port             = var.target_port
}
