resource "aws_lb" "this" {
  name                       = var.name
  internal                   = var.internal
  load_balancer_type         = var.load_balancer_type
  security_groups            = var.security_group_ids
  subnets                    = var.subnet_ids
  ip_address_type            = var.ip_address_type
  enable_deletion_protection = var.enable_deletion_protection

  tags = merge(
    {
      Name      = var.name
      ManagedBy = "terraform"
      Module    = "application_load_balancer"
    },
    var.tags
  )
}

resource "aws_lb_target_group" "this" {
  for_each = var.target_groups

  name                 = each.value.name
  port                 = each.value.port
  protocol             = each.value.protocol
  vpc_id               = var.vpc_id
  target_type          = try(each.value.target_type, "instance")
  deregistration_delay = try(each.value.deregistration_delay, null)

  dynamic "health_check" {
    for_each = try(each.value.health_check, null) == null ? [] : [each.value.health_check]
    content {
      enabled             = try(health_check.value.enabled, true)
      healthy_threshold   = try(health_check.value.healthy_threshold, null)
      interval            = try(health_check.value.interval, null)
      matcher             = try(health_check.value.matcher, null)
      path                = try(health_check.value.path, null)
      port                = try(health_check.value.port, null)
      protocol            = try(health_check.value.protocol, null)
      timeout             = try(health_check.value.timeout, null)
      unhealthy_threshold = try(health_check.value.unhealthy_threshold, null)
    }
  }

  tags = merge(
    {
      Name      = each.value.name
      ManagedBy = "terraform"
      Module    = "application_load_balancer"
    },
    var.tags
  )
}

resource "aws_lb_listener" "this" {
  for_each = var.listeners

  load_balancer_arn = aws_lb.this.arn
  port              = each.value.port
  protocol          = each.value.protocol
  certificate_arn   = try(each.value.certificate_arn, null)
  ssl_policy        = try(each.value.ssl_policy, null)

  dynamic "default_action" {
    for_each = each.value.default_action.type == "forward" ? [each.value.default_action] : []
    content {
      type             = "forward"
      target_group_arn = aws_lb_target_group.this[default_action.value.target_group_key].arn
    }
  }

  dynamic "default_action" {
    for_each = each.value.default_action.type == "fixed-response" ? [each.value.default_action] : []
    content {
      type = "fixed-response"
      fixed_response {
        content_type = default_action.value.fixed_response.content_type
        message_body = try(default_action.value.fixed_response.message_body, null)
        status_code  = default_action.value.fixed_response.status_code
      }
    }
  }

  dynamic "default_action" {
    for_each = each.value.default_action.type == "redirect" ? [each.value.default_action] : []
    content {
      type = "redirect"
      redirect {
        status_code = default_action.value.redirect.status_code
        host        = try(default_action.value.redirect.host, null)
        path        = try(default_action.value.redirect.path, null)
        port        = try(default_action.value.redirect.port, null)
        protocol    = try(default_action.value.redirect.protocol, null)
        query       = try(default_action.value.redirect.query, null)
      }
    }
  }

  lifecycle {
    precondition {
      condition = (
        each.value.default_action.type != "forward" ||
        contains(keys(var.target_groups), each.value.default_action.target_group_key)
      )
      error_message = "Listener default_action.target_group_key must exist in var.target_groups."
    }
  }
}

resource "aws_lb_listener_rule" "this" {
  for_each = var.listener_rules

  listener_arn = aws_lb_listener.this[each.value.listener_key].arn
  priority     = each.value.priority

  dynamic "condition" {
    for_each = length(try(each.value.conditions.host_headers, [])) == 0 ? [] : [each.value.conditions.host_headers]
    content {
      host_header {
        values = condition.value
      }
    }
  }

  dynamic "condition" {
    for_each = length(try(each.value.conditions.path_patterns, [])) == 0 ? [] : [each.value.conditions.path_patterns]
    content {
      path_pattern {
        values = condition.value
      }
    }
  }

  dynamic "action" {
    for_each = each.value.action.type == "forward" ? [each.value.action] : []
    content {
      type             = "forward"
      target_group_arn = aws_lb_target_group.this[action.value.target_group_key].arn
    }
  }

  dynamic "action" {
    for_each = each.value.action.type == "fixed-response" ? [each.value.action] : []
    content {
      type = "fixed-response"
      fixed_response {
        content_type = action.value.fixed_response.content_type
        message_body = try(action.value.fixed_response.message_body, null)
        status_code  = action.value.fixed_response.status_code
      }
    }
  }

  dynamic "action" {
    for_each = each.value.action.type == "redirect" ? [each.value.action] : []
    content {
      type = "redirect"
      redirect {
        status_code = action.value.redirect.status_code
        host        = try(action.value.redirect.host, null)
        path        = try(action.value.redirect.path, null)
        port        = try(action.value.redirect.port, null)
        protocol    = try(action.value.redirect.protocol, null)
        query       = try(action.value.redirect.query, null)
      }
    }
  }

  lifecycle {
    precondition {
      condition = (
        each.value.action.type != "forward" ||
        contains(keys(var.target_groups), each.value.action.target_group_key)
      )
      error_message = "Listener rule action.target_group_key must exist in var.target_groups."
    }
  }
}

resource "aws_lb_target_group_attachment" "this" {
  for_each = var.target_group_attachments

  target_group_arn  = aws_lb_target_group.this[each.value.target_group_key].arn
  target_id         = each.value.target_id
  port              = try(each.value.port, null)
  availability_zone = try(each.value.availability_zone, null)

  lifecycle {
    precondition {
      condition     = contains(keys(var.target_groups), each.value.target_group_key)
      error_message = "Target group attachment target_group_key must exist in var.target_groups."
    }
  }
}
