output "cluster_name" {
  value       = var.cluster_name
  description = "Shared cluster name."
}

output "network_mode" {
  value       = var.create_vpc ? "managed-by-terraform" : "existing-network-reuse"
  description = "Whether the environment creates its own VPC or reuses an existing one."
}

output "shared_namespaces" {
  value       = local.shared_namespaces
  description = "Namespaces planned for the shared cluster."
}

output "control_plane_endpoint" {
  value       = var.enable_control_plane_internal_nlb ? module.control_plane_internal_nlb[0].dns_name : var.cluster_endpoint_dns_name
  description = "Control plane endpoint name used by kubeadm."
}

output "vpc_id" {
  value       = local.vpc_id
  description = "VPC ID for the cluster."
}

output "public_subnet_ids" {
  value       = local.public_subnet_ids
  description = "Public subnet IDs."
}

output "private_subnet_ids" {
  value       = local.private_subnet_ids
  description = "Private subnet IDs."
}

output "security_group_ids" {
  value = {
    cluster_internal = local.cluster_internal_sg_id
    control_plane    = local.control_plane_sg_id
    worker           = local.worker_sg_id
  }
  description = "Security group IDs used by the cluster."
}

output "ami_id" {
  value       = data.aws_ami.node.id
  description = "AMI selected for the cluster nodes."
}

output "control_plane_instances" {
  value = {
    ids         = module.control_plane.instance_ids
    private_ips = module.control_plane.private_ips
    names       = module.control_plane.instance_names
  }
  description = "Control plane instance details."
}

output "worker_pools" {
  value = {
    app_pool = {
      ids         = module.app_pool.instance_ids
      private_ips = module.app_pool.private_ips
      names       = module.app_pool.instance_names
    }
    ai_serving_pool = {
      ids         = module.ai_serving_pool.instance_ids
      private_ips = module.ai_serving_pool.private_ips
      names       = module.ai_serving_pool.instance_names
    }
    system_pool = {
      ids         = module.system_pool.instance_ids
      private_ips = module.system_pool.private_ips
      names       = module.system_pool.instance_names
    }
    dev_pool = {
      ids         = module.dev_pool.instance_ids
      private_ips = module.dev_pool.private_ips
      names       = module.dev_pool.instance_names
    }
  }
  description = "Worker pool instance details."
}

output "iam_profiles" {
  value = {
    control_plane = module.control_plane_iam.instance_profile_name
    worker        = module.worker_iam.instance_profile_name
  }
  description = "IAM instance profiles attached to nodes."
}
