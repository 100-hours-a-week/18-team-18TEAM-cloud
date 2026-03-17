locals {
  new_alb_security_group_ids = var.alb_sg_migration_mode == "legacy" ? [] : [
    module.alb_edge_v2[0].id,
  ]

  computed_alb_security_group_ids = var.alb_sg_migration_mode == "legacy" ? var.alb_security_group_ids : (
    var.alb_sg_migration_mode == "dual" ? distinct(concat(var.alb_security_group_ids, local.new_alb_security_group_ids)) : local.new_alb_security_group_ids
  )
}

module "application_load_balancer" {
  source = "../../modules/application_load_balancer"

  # prod ALB traffic policy: 80/443 inbound, /api -> 8080, /ai -> 8000, default -> 3000.
  name               = var.alb_name
  internal           = var.alb_internal
  security_group_ids = local.computed_alb_security_group_ids
  subnet_ids         = var.alb_subnet_ids
  vpc_id             = data.terraform_remote_state.network.outputs.vpc_id

  target_groups = {
    prod_fe = {
      name     = "bizkit-tg-prod-fe"
      port     = 80
      protocol = "HTTP"
    }
    prod_be = {
      name     = "bizkit-tg-prod-be"
      port     = 80
      protocol = "HTTP"
      health_check = {
        enabled             = true
        healthy_threshold   = 5
        interval            = 30
        matcher             = "200"
        path                = "/actuator/health"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 5
        unhealthy_threshold = 2
      }
    }
    prod_ai = {
      name     = "bizkit-tg-prod-ai"
      port     = 80
      protocol = "HTTP"
      health_check = {
        enabled             = true
        healthy_threshold   = 5
        interval            = 30
        matcher             = "200"
        path                = "/ai/health"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 5
        unhealthy_threshold = 2
      }
    }
  }

  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"
      default_action = {
        type             = "forward"
        target_group_key = "prod_fe"
      }
    }
    https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = var.alb_certificate_arn
      ssl_policy      = var.alb_ssl_policy
      default_action = {
        type             = "forward"
        target_group_key = "prod_fe"
      }
    }
  }

  listener_rules = {
    http_api = {
      listener_key = "http"
      priority     = 1
      conditions = {
        path_patterns = ["/api/*"]
      }
      action = {
        type             = "forward"
        target_group_key = "prod_be"
      }
    }
    http_ai = {
      listener_key = "http"
      priority     = 2
      conditions = {
        path_patterns = ["/ai/*"]
      }
      action = {
        type             = "forward"
        target_group_key = "prod_ai"
      }
    }
    https_api = {
      listener_key = "https"
      priority     = 1
      conditions = {
        path_patterns = ["/api/*"]
      }
      action = {
        type             = "forward"
        target_group_key = "prod_be"
      }
    }
    https_ai = {
      listener_key = "https"
      priority     = 2
      conditions = {
        path_patterns = ["/ai/*"]
      }
      action = {
        type             = "forward"
        target_group_key = "prod_ai"
      }
    }
  }

  target_group_attachments = {
    prod_fe_app = {
      target_group_key = "prod_fe"
      target_id        = module.compute_single.instance_id
      port             = 3000
    }
    prod_be_app = {
      target_group_key = "prod_be"
      target_id        = module.compute_single.instance_id
      port             = 8080
    }
    prod_ai_app = {
      target_group_key = "prod_ai"
      target_id        = module.compute_single.instance_id
      port             = 8000
    }
  }

  tags = {
    Project = var.project
    Env     = var.env
    Tier    = "edge"
  }
}
