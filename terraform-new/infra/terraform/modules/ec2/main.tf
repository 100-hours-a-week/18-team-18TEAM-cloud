locals {
  node_names = [for idx in range(var.instance_count) : "${var.name_prefix}-${idx + 1}"]
}

resource "aws_instance" "this" {
  count = var.instance_count

  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_ids[count.index % length(var.subnet_ids)]
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.key_name

  iam_instance_profile        = var.instance_profile_name
  associate_public_ip_address = false
  user_data_replace_on_change = true

  user_data = templatefile("${path.module}/templates/user_data.sh.tftpl", {
    cluster_name       = var.cluster_name
    kubernetes_version = var.kubernetes_version
    hostname           = local.node_names[count.index]
    node_pool          = var.node_pool
    node_role          = var.node_role
    kube_reserved      = var.kube_reserved
    system_reserved    = var.system_reserved
    eviction_hard      = var.eviction_hard
    kubernetes_channel = var.kubernetes_channel
  })

  root_block_device {
    volume_size           = var.volume_size
    volume_type           = var.volume_type
    encrypted             = var.volume_encrypted
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = merge(var.tags, {
    Name               = local.node_names[count.index]
    "bizkit:cluster"   = var.cluster_name
    "bizkit:node-pool" = var.node_pool
    "bizkit:node-role" = var.node_role
  })
}
