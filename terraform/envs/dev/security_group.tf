locals {
  sg_name_prefix = "bizkit-sg-${var.env}"
}

module "ssh" {
  count  = var.remove_legacy_sg ? 0 : 1
  source = "../../modules/security_group"

  name        = "bizkit-dev-ssh-sg"
  description = "ssh for developers"

  vpc_id = data.terraform_remote_state.network.outputs.vpc_id


  ingress_rules = [
    {
      description     = "from vpn"
      from_port       = var.ssh_port
      to_port         = var.ssh_port
      protocol        = "tcp"
      security_groups = [var.vpn_sg_id]
    },
  ]

  egress_rules = [
    {
      description = "allow all outbound"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description     = "allow all outbound to dev nat sg"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      security_groups = [var.dev_nat_sg_id]
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

  name        = "bizkit-dev-webserver-sg"
  description = "allow http/https request from anywhere"

  vpc_id = data.terraform_remote_state.network.outputs.vpc_id


  ingress_rules = [
    {
      description     = "allow HTTP frrom vpn"
      from_port       = var.http_port
      to_port         = var.http_port
      protocol        = "tcp"
      security_groups = [var.vpn_sg_id]
    },
    {
      description     = "allow HTTPS frrom vpn"
      from_port       = var.https_port
      to_port         = var.https_port
      protocol        = "tcp"
      security_groups = [var.vpn_sg_id]
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

  name        = "bizkit-dev-monitor-ec2-sg"
  description = "monitor sg for dev ec2"

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
    Name    = "bizkit-sg-${var.env}-app-metrics"
  }
}

module "ssh_v2" {
  count  = var.sg_migration_mode == "legacy" ? 0 : 1
  source = "../../modules/security_group"

  name        = "${local.sg_name_prefix}-ssh"
  description = "[dev] Security group for SSH access from VPN to dev instances"

  vpc_id = data.terraform_remote_state.network.outputs.vpc_id

  ingress_rules = [
    {
      description     = "[dev] Allow SSH (22) from VPN security group"
      from_port       = var.ssh_port
      to_port         = var.ssh_port
      protocol        = "tcp"
      security_groups = [var.vpn_sg_id]
    },
  ]

  egress_rules = [
    {
      description = "[dev] Allow all outbound traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description     = "[dev] Allow outbound traffic to dev NAT security group"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      security_groups = [var.dev_nat_sg_id]
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
  description = "[dev] Security group for HTTP/HTTPS access from VPN to dev application"

  vpc_id = data.terraform_remote_state.network.outputs.vpc_id

  ingress_rules = [
    {
      description     = "[dev] Allow HTTP (80) from VPN security group"
      from_port       = var.http_port
      to_port         = var.http_port
      protocol        = "tcp"
      security_groups = [var.vpn_sg_id]
    },
    {
      description     = "[dev] Allow HTTPS (443) from VPN security group"
      from_port       = var.https_port
      to_port         = var.https_port
      protocol        = "tcp"
      security_groups = [var.vpn_sg_id]
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
  description = "[dev] Security group for monitoring access to dev application metrics"

  vpc_id = data.terraform_remote_state.network.outputs.vpc_id

  ingress_rules = [
    {
      description     = "[dev] Allow Micrometer metrics (8080) from monitoring security group"
      from_port       = 8080
      to_port         = 8080
      protocol        = "tcp"
      security_groups = [var.monitoring_sg_id]
    },
    {
      description     = "[dev] Allow Prometheus node metrics (9100) from monitoring security group"
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
