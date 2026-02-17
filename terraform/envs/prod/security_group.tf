locals {
  sg_name_prefix = "bizkit-sg-${var.env}"
}

moved {
  from = module.ssh.aws_security_group.this
  to   = module.ssh[0].aws_security_group.this
}

moved {
  from = module.webserver.aws_security_group.this
  to   = module.webserver[0].aws_security_group.this
}

moved {
  from = module.monitor.aws_security_group.this
  to   = module.monitor[0].aws_security_group.this
}

module "ssh" {
  count  = var.remove_legacy_sg ? 0 : 1
  source = "../../modules/security_group"

  name        = "bizkit-prod-ssh-sg"
  description = "ssh for developers"

  vpc_id = data.terraform_remote_state.network.outputs.vpc_id

  ingress_rules = [
    {
      description     = "allow ssh from vpn"
      from_port       = var.ssh_port
      to_port         = var.ssh_port
      protocol        = "tcp"
      security_groups = [var.vpn_sg_id]
    },
  ]

  tags = {
    Project = var.project
    Env     = var.env
    Tier    = "edge"
    Name    = "bizkit-sg-${var.env}-ssh"
  }
}


module "webserver" {
  count  = var.remove_legacy_sg ? 0 : 1
  source = "../../modules/security_group"

  name        = "bizkit-prod-webserver-sg"
  description = "allow http/https from anywhere"

  vpc_id = data.terraform_remote_state.network.outputs.vpc_id

  ingress_rules = [
    {
      description = "allow HTTP from anywhere"
      from_port   = var.http_port
      to_port     = var.http_port
      protocol    = "tcp"
      cidr_blocks = [var.public_cidr]
    },
    {
      description = "allow HTTPS from anywhere"
      from_port   = var.https_port
      to_port     = var.https_port
      protocol    = "tcp"
      cidr_blocks = [var.public_cidr]
    }
  ]

  tags = {
    Project = var.project
    Env     = var.env
    Tier    = "edge"
    Name    = "bizkit-sg-${var.env}-webserver"
  }
}

module "monitor" {
  count  = var.remove_legacy_sg ? 0 : 1
  source = "../../modules/security_group"

  name        = "bizkit-prod-monitor-ec2-sg"
  description = "monitor sg for prod ec2"

  vpc_id = data.terraform_remote_state.network.outputs.vpc_id

  ingress_rules = [
    {
      description     = "micrometer"
      from_port       = 8080
      to_port         = 8080
      protocol        = "tcp"
      security_groups = [var.monitoring_sg_id]
    },
    {
      description     = "prometheus"
      from_port       = 9100
      to_port         = 9100
      protocol        = "tcp"
      security_groups = [var.monitoring_sg_id]
    },
  ]

  tags = {
    Project = var.project
    Env     = var.env
    Tier    = "monitoring"
    Name    = "bizkit-sg-${var.env}-monitor-ec2"
  }
}

module "ssh_v2" {
  count  = var.sg_migration_mode == "legacy" ? 0 : 1
  source = "../../modules/security_group"

  name        = "${local.sg_name_prefix}-ssh"
  description = "[prod] Security group for SSH access from VPN to prod instances"

  vpc_id = data.terraform_remote_state.network.outputs.vpc_id

  ingress_rules = [
    {
      description     = "[prod] Allow SSH (22) from VPN security group"
      from_port       = var.ssh_port
      to_port         = var.ssh_port
      protocol        = "tcp"
      security_groups = [var.vpn_sg_id]
    },
  ]

  tags = {
    Project = var.project
    Env     = var.env
    Tier    = "edge"
    Name    = "bizkit-sg-${var.env}-ssh"
  }
}

module "webserver_v2" {
  count  = var.sg_migration_mode == "legacy" ? 0 : 1
  source = "../../modules/security_group"

  name        = "${local.sg_name_prefix}-webserver"
  description = "[prod] Security group for HTTP/HTTPS access from internet to prod application"

  vpc_id = data.terraform_remote_state.network.outputs.vpc_id

  ingress_rules = [
    {
      description = "[prod] Allow HTTP (80) from internet"
      from_port   = var.http_port
      to_port     = var.http_port
      protocol    = "tcp"
      cidr_blocks = [var.public_cidr]
    },
    {
      description = "[prod] Allow HTTPS (443) from internet"
      from_port   = var.https_port
      to_port     = var.https_port
      protocol    = "tcp"
      cidr_blocks = [var.public_cidr]
    }
  ]

  tags = {
    Project = var.project
    Env     = var.env
    Tier    = "edge"
    Name    = "bizkit-sg-${var.env}-webserver"
  }
}

module "monitor_v2" {
  count  = var.sg_migration_mode == "legacy" ? 0 : 1
  source = "../../modules/security_group"

  name        = "${local.sg_name_prefix}-app-metrics"
  description = "[prod] Security group for monitoring access to prod application metrics"

  vpc_id = data.terraform_remote_state.network.outputs.vpc_id

  ingress_rules = [
    {
      description     = "[prod] Allow Micrometer metrics (8080) from monitoring security group"
      from_port       = 8080
      to_port         = 8080
      protocol        = "tcp"
      security_groups = [var.monitoring_sg_id]
    },
    {
      description     = "[prod] Allow Prometheus node metrics (9100) from monitoring security group"
      from_port       = 9100
      to_port         = 9100
      protocol        = "tcp"
      security_groups = [var.monitoring_sg_id]
    },
  ]

  tags = {
    Project = var.project
    Env     = var.env
    Tier    = "monitoring"
    Name    = "bizkit-sg-${var.env}-app-metrics"
  }
}

module "alb_edge_v2" {
  count  = var.alb_sg_migration_mode == "legacy" ? 0 : 1
  source = "../../modules/security_group"

  name        = "bizkit-sg-${var.env}-edge-alb"
  description = "[prod] Security group for internet-facing ALB"

  vpc_id = data.terraform_remote_state.network.outputs.vpc_id

  ingress_rules = [
    {
      description = "[prod] Allow HTTP (80) from internet"
      from_port   = var.http_port
      to_port     = var.http_port
      protocol    = "tcp"
      cidr_blocks = [var.public_cidr]
    },
    {
      description = "[prod] Allow HTTPS (443) from internet"
      from_port   = var.https_port
      to_port     = var.https_port
      protocol    = "tcp"
      cidr_blocks = [var.public_cidr]
    }
  ]

  tags = {
    Project = var.project
    Env     = var.env
    Tier    = "edge"
    Name    = "bizkit-sg-${var.env}-edge-alb"
  }
}

module "app_from_alb_v2" {
  count  = var.alb_sg_migration_mode == "legacy" ? 0 : 1
  source = "../../modules/security_group"

  name        = "bizkit-sg-${var.env}-app-from-alb"
  description = "[prod] Security group for application traffic from prod ALB"

  vpc_id = data.terraform_remote_state.network.outputs.vpc_id

  ingress_rules = [
    {
      description     = "[prod] Allow FE traffic (3000) from ALB SG"
      from_port       = 3000
      to_port         = 3000
      protocol        = "tcp"
      security_groups = [module.alb_edge_v2[0].id]
    },
    {
      description     = "[prod] Allow BE traffic (8080) from ALB SG"
      from_port       = 8080
      to_port         = 8080
      protocol        = "tcp"
      security_groups = [module.alb_edge_v2[0].id]
    },
    {
      description     = "[prod] Allow AI traffic (8000) from ALB SG"
      from_port       = 8000
      to_port         = 8000
      protocol        = "tcp"
      security_groups = [module.alb_edge_v2[0].id]
    },
  ]

  tags = {
    Project = var.project
    Env     = var.env
    Tier    = "edge"
    Name    = "bizkit-sg-${var.env}-app-from-alb"
  }
}
