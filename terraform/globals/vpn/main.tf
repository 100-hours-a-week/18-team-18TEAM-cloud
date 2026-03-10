resource "aws_security_group" "vpn" {
  count = var.vpn_sg_migration_mode == "new" ? 0 : 1

  name        = var.vpn_security_group_name
  description = var.vpn_security_group_description
  vpc_id      = var.vpc_id

  # WireGuard
  ingress {
    protocol    = "udp"
    from_port   = 51820
    to_port     = 51820
    cidr_blocks = var.allowed_udp_cidrs
  }

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = var.allowed_ssh_cidrs
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name      = var.vpn_security_group_name
    ManagedBy = "terraform"
    Module    = "globals/vpn"
  })

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_security_group" "vpn_v2" {
  count = var.vpn_sg_migration_mode == "legacy" ? 0 : 1

  name        = var.vpn_security_group_name_v2
  description = var.vpn_security_group_description_v2
  vpc_id      = var.vpc_id

  # WireGuard
  ingress {
    protocol    = "udp"
    from_port   = 51820
    to_port     = 51820
    cidr_blocks = var.allowed_udp_cidrs
  }

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = var.allowed_ssh_cidrs
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name      = var.vpn_security_group_name_v2
    ManagedBy = "terraform"
    Module    = "globals/vpn"
  })
}

locals {
  legacy_vpn_sg_id = var.vpn_sg_migration_mode == "new" ? null : aws_security_group.vpn[0].id
  new_vpn_sg_id    = var.vpn_sg_migration_mode == "legacy" ? null : aws_security_group.vpn_v2[0].id

  vpn_instance_sg_ids = (
    var.vpn_sg_migration_mode == "legacy" ? [local.legacy_vpn_sg_id] :
    var.vpn_sg_migration_mode == "dual" ? compact(distinct([local.legacy_vpn_sg_id, local.new_vpn_sg_id])) :
    compact([local.new_vpn_sg_id])
  )
}

resource "aws_instance" "vpn" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.public_subnet_id
  key_name      = var.key_name

  vpc_security_group_ids = local.vpn_instance_sg_ids

  source_dest_check = var.source_dest_check

  user_data = templatefile("${path.module}/cloud-init/wireguard.sh.tftpl", {
    server_url      = var.server_url
    server_port     = var.server_port
    peers           = tostring(var.peers)
    peer_dns        = var.peer_dns
    internal_subnet = var.internal_subnet
    allowed_ips     = var.allowed_ips
  })
  user_data_replace_on_change = var.user_data_overwrite_ok

  tags = merge(var.tags, {
    Name      = var.name
    ManagedBy = "terraform"
    Module    = "globals/vpn"
  })

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [user_data]
  }
}

resource "aws_eip" "vpn" {
  domain = "vpc"

  tags = merge(var.tags, {
    Name      = var.vpn_eip_name
    ManagedBy = "terraform"
    Module    = "globals/vpn"
  })

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_eip_association" "vpn" {
  instance_id   = aws_instance.vpn.id
  allocation_id = aws_eip.vpn.id
}
