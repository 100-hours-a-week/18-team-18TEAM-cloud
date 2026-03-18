locals {
  name_prefix = "${var.project_name}-${var.environment_name}-k8s"

  tags = merge({
    project           = var.project_name
    environment       = var.environment_name
    cluster           = var.cluster_name
    "k8s-scope"       = "prod-cluster"
    "k8s-namespaces"  = "dev/prod"
    managedBy         = "terraform"
    architecture      = var.ami_architecture
    bootstrapStrategy = "kubeadm"
  }, var.default_tags)

  shared_namespaces = ["dev", "prod"]

  common_egress_rules = [
    {
      description      = "Allow all outbound traffic"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      security_groups  = []
      self             = false
    }
  ]

  vpc_id = var.create_vpc ? module.vpc[0].vpc_id : var.existing_vpc_id

  public_subnet_ids = var.create_vpc ? module.vpc[0].public_subnet_ids : var.existing_public_subnet_ids

  private_subnet_ids = var.create_vpc ? module.vpc[0].private_subnet_ids : var.existing_private_subnet_ids

  control_plane_subnet_ids = length(var.control_plane_subnet_ids) > 0 ? var.control_plane_subnet_ids : local.private_subnet_ids
  app_pool_subnet_ids      = length(var.app_pool_subnet_ids) > 0 ? var.app_pool_subnet_ids : local.private_subnet_ids
  ai_pool_subnet_ids       = length(var.ai_serving_pool_subnet_ids) > 0 ? var.ai_serving_pool_subnet_ids : local.private_subnet_ids
  system_pool_subnet_ids   = length(var.system_pool_subnet_ids) > 0 ? var.system_pool_subnet_ids : local.private_subnet_ids
  dev_pool_subnet_ids      = length(var.dev_pool_subnet_ids) > 0 ? var.dev_pool_subnet_ids : local.private_subnet_ids
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.tags
  }
}

data "aws_ami" "node" {
  most_recent = true
  owners      = var.ami_owners

  filter {
    name   = "name"
    values = [var.ami_name_pattern]
  }

  filter {
    name   = "architecture"
    values = [var.ami_architecture]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "terraform_data" "input_validation" {
  input = {
    create_vpc                  = var.create_vpc
    existing_vpc_id             = var.existing_vpc_id
    existing_private_subnet_ids = var.existing_private_subnet_ids
    allowed_ssh_cidrs           = var.allowed_ssh_cidrs
    allowed_ssh_security_groups = var.allowed_ssh_security_group_ids
  }

  lifecycle {
    precondition {
      condition     = length(var.allowed_ssh_cidrs) > 0 || length(var.allowed_ssh_security_group_ids) > 0
      error_message = "At least one restricted SSH source must be provided. Do not leave SSH open to the world."
    }

    precondition {
      condition = var.create_vpc ? (
        length(var.availability_zones) >= 2 &&
        length(var.public_subnet_cidrs) == length(var.availability_zones) &&
        length(var.private_subnet_cidrs) == length(var.availability_zones) &&
        var.vpc_cidr != null
        ) : (
        var.existing_vpc_id != null &&
        length(var.existing_private_subnet_ids) >= 2
      )
      error_message = "If create_vpc is true, provide VPC CIDR and at least two AZ-aligned public/private subnet CIDRs. If create_vpc is false, provide existing_vpc_id and at least two existing_private_subnet_ids."
    }
  }
}

module "vpc" {
  count  = var.create_vpc ? 1 : 0
  source = "../../modules/vpc"

  name_prefix          = local.name_prefix
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  enable_nat_gateway   = var.enable_nat_gateway
  single_nat_gateway   = var.single_nat_gateway
  tags                 = local.tags
}

module "cluster_internal_sg" {
  count  = var.existing_cluster_internal_security_group_id == null ? 1 : 0
  source = "../../modules/security-group"

  name        = "${local.name_prefix}-cluster-internal"
  description = "Cluster internal SG for kubeadm self-managed nodes."
  vpc_id      = local.vpc_id
  ingress_rules = [
    {
      description      = "Allow all traffic between cluster nodes"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      cidr_blocks      = []
      ipv6_cidr_blocks = []
      security_groups  = []
      self             = true
    }
  ]
  egress_rules = local.common_egress_rules
  tags         = local.tags
}

locals {
  cluster_internal_sg_id = coalesce(var.existing_cluster_internal_security_group_id, try(module.cluster_internal_sg[0].id, null))
}

module "control_plane_sg" {
  count  = var.existing_control_plane_security_group_id == null ? 1 : 0
  source = "../../modules/security-group"

  name        = "${local.name_prefix}-control-plane"
  description = "Control plane SG for Bizkit self-managed Kubernetes."
  vpc_id      = local.vpc_id
  ingress_rules = concat(
    [
      {
        description      = "SSH from admin CIDRs or Bastion/VPN SG"
        protocol         = "tcp"
        from_port        = 22
        to_port          = 22
        cidr_blocks      = var.allowed_ssh_cidrs
        ipv6_cidr_blocks = []
        security_groups  = var.allowed_ssh_security_group_ids
        self             = false
      },
      {
        description      = "kube-apiserver from cluster internal SG"
        protocol         = "tcp"
        from_port        = 6443
        to_port          = 6443
        cidr_blocks      = []
        ipv6_cidr_blocks = []
        security_groups  = [local.cluster_internal_sg_id]
        self             = false
      },
      {
        description      = "etcd peer and client traffic between control planes"
        protocol         = "tcp"
        from_port        = 2379
        to_port          = 2380
        cidr_blocks      = []
        ipv6_cidr_blocks = []
        security_groups  = []
        self             = true
      },
      {
        description      = "controller-manager and scheduler internal traffic"
        protocol         = "tcp"
        from_port        = 10257
        to_port          = 10259
        cidr_blocks      = []
        ipv6_cidr_blocks = []
        security_groups  = []
        self             = true
      }
    ],
    length(var.allowed_control_plane_api_cidrs) > 0 || length(var.allowed_control_plane_api_security_group_ids) > 0 ? [
      {
        description      = "kube-apiserver from restricted admin sources"
        protocol         = "tcp"
        from_port        = 6443
        to_port          = 6443
        cidr_blocks      = var.allowed_control_plane_api_cidrs
        ipv6_cidr_blocks = []
        security_groups  = var.allowed_control_plane_api_security_group_ids
        self             = false
      }
    ] : []
  )
  egress_rules = local.common_egress_rules
  tags         = local.tags
}

module "worker_sg" {
  count  = var.existing_worker_security_group_id == null ? 1 : 0
  source = "../../modules/security-group"

  name        = "${local.name_prefix}-worker"
  description = "Worker SG for Bizkit self-managed Kubernetes."
  vpc_id      = local.vpc_id
  ingress_rules = concat(
    [
      {
        description      = "SSH from admin CIDRs or Bastion/VPN SG"
        protocol         = "tcp"
        from_port        = 22
        to_port          = 22
        cidr_blocks      = var.allowed_ssh_cidrs
        ipv6_cidr_blocks = []
        security_groups  = var.allowed_ssh_security_group_ids
        self             = false
      },
      {
        description      = "kubelet API from control plane SG"
        protocol         = "tcp"
        from_port        = 10250
        to_port          = 10250
        cidr_blocks      = []
        ipv6_cidr_blocks = []
        security_groups  = [coalesce(var.existing_control_plane_security_group_id, try(module.control_plane_sg[0].id, null))]
        self             = false
      }
    ],
    length(var.ingress_source_cidrs) > 0 || length(var.ingress_source_security_group_ids) > 0 ? [
      {
        description      = "Future HAProxy HTTP NodePort source"
        protocol         = "tcp"
        from_port        = 30080
        to_port          = 30080
        cidr_blocks      = var.ingress_source_cidrs
        ipv6_cidr_blocks = []
        security_groups  = var.ingress_source_security_group_ids
        self             = false
      },
      {
        description      = "Future HAProxy HTTPS NodePort source"
        protocol         = "tcp"
        from_port        = 30443
        to_port          = 30443
        cidr_blocks      = var.ingress_source_cidrs
        ipv6_cidr_blocks = []
        security_groups  = var.ingress_source_security_group_ids
        self             = false
      },
      {
        description      = "Future HAProxy healthz source"
        protocol         = "tcp"
        from_port        = 31024
        to_port          = 31024
        cidr_blocks      = var.ingress_source_cidrs
        ipv6_cidr_blocks = []
        security_groups  = var.ingress_source_security_group_ids
        self             = false
      }
    ] : []
  )
  egress_rules = local.common_egress_rules
  tags         = local.tags
}

locals {
  control_plane_sg_id = coalesce(var.existing_control_plane_security_group_id, try(module.control_plane_sg[0].id, null))
  worker_sg_id        = coalesce(var.existing_worker_security_group_id, try(module.worker_sg[0].id, null))
}

module "control_plane_iam" {
  source = "../../modules/iam"

  role_name                      = "${local.name_prefix}-control-plane"
  instance_profile_name          = "${local.name_prefix}-control-plane"
  create_instance_profile        = var.create_instance_profiles
  additional_managed_policy_arns = var.control_plane_additional_policy_arns
  tags                           = local.tags
}

module "worker_iam" {
  source = "../../modules/iam"

  role_name                      = "${local.name_prefix}-worker"
  instance_profile_name          = "${local.name_prefix}-worker"
  create_instance_profile        = var.create_instance_profiles
  additional_managed_policy_arns = var.worker_additional_policy_arns
  tags                           = local.tags
}

module "control_plane" {
  source = "../../modules/ec2"

  name_prefix           = "${local.name_prefix}-cp"
  instance_count        = var.control_plane_count
  ami_id                = data.aws_ami.node.id
  instance_type         = var.control_plane_instance_type
  subnet_ids            = local.control_plane_subnet_ids
  security_group_ids    = compact(concat([local.cluster_internal_sg_id, local.control_plane_sg_id], var.additional_node_security_group_ids))
  key_name              = var.key_pair_name
  instance_profile_name = module.control_plane_iam.instance_profile_name
  cluster_name          = var.cluster_name
  node_pool             = "control-plane"
  node_role             = "control-plane"
  kubernetes_version    = var.kubernetes_version
  kubernetes_channel    = var.kubernetes_channel
  kube_reserved         = var.kube_reserved
  system_reserved       = var.system_reserved
  eviction_hard         = var.eviction_hard
  volume_size           = var.root_volume_size_gib
  volume_type           = var.root_volume_type
  volume_encrypted      = var.root_volume_encrypted
  tags                  = local.tags
}

module "app_pool" {
  source = "../../modules/ec2"

  name_prefix           = "${local.name_prefix}-app"
  instance_count        = var.app_pool_count
  ami_id                = data.aws_ami.node.id
  instance_type         = var.app_pool_instance_type
  subnet_ids            = local.app_pool_subnet_ids
  security_group_ids    = compact(concat([local.cluster_internal_sg_id, local.worker_sg_id], var.additional_node_security_group_ids))
  key_name              = var.key_pair_name
  instance_profile_name = module.worker_iam.instance_profile_name
  cluster_name          = var.cluster_name
  node_pool             = "app-pool"
  node_role             = "worker"
  kubernetes_version    = var.kubernetes_version
  kubernetes_channel    = var.kubernetes_channel
  kube_reserved         = var.kube_reserved
  system_reserved       = var.system_reserved
  eviction_hard         = var.eviction_hard
  volume_size           = var.root_volume_size_gib
  volume_type           = var.root_volume_type
  volume_encrypted      = var.root_volume_encrypted
  tags                  = local.tags
}

module "ai_serving_pool" {
  source = "../../modules/ec2"

  name_prefix           = "${local.name_prefix}-ai"
  instance_count        = var.ai_serving_pool_count
  ami_id                = data.aws_ami.node.id
  instance_type         = var.ai_serving_pool_instance_type
  subnet_ids            = local.ai_pool_subnet_ids
  security_group_ids    = compact(concat([local.cluster_internal_sg_id, local.worker_sg_id], var.additional_node_security_group_ids))
  key_name              = var.key_pair_name
  instance_profile_name = module.worker_iam.instance_profile_name
  cluster_name          = var.cluster_name
  node_pool             = "ai-serving-pool"
  node_role             = "worker"
  kubernetes_version    = var.kubernetes_version
  kubernetes_channel    = var.kubernetes_channel
  kube_reserved         = var.kube_reserved
  system_reserved       = var.system_reserved
  eviction_hard         = var.eviction_hard
  volume_size           = var.root_volume_size_gib
  volume_type           = var.root_volume_type
  volume_encrypted      = var.root_volume_encrypted
  tags                  = local.tags
}

module "system_pool" {
  source = "../../modules/ec2"

  name_prefix           = "${local.name_prefix}-system"
  instance_count        = var.system_pool_count
  ami_id                = data.aws_ami.node.id
  instance_type         = var.system_pool_instance_type
  subnet_ids            = local.system_pool_subnet_ids
  security_group_ids    = compact(concat([local.cluster_internal_sg_id, local.worker_sg_id], var.additional_node_security_group_ids))
  key_name              = var.key_pair_name
  instance_profile_name = module.worker_iam.instance_profile_name
  cluster_name          = var.cluster_name
  node_pool             = "system-pool"
  node_role             = "worker"
  kubernetes_version    = var.kubernetes_version
  kubernetes_channel    = var.kubernetes_channel
  kube_reserved         = var.kube_reserved
  system_reserved       = var.system_reserved
  eviction_hard         = var.eviction_hard
  volume_size           = var.root_volume_size_gib
  volume_type           = var.root_volume_type
  volume_encrypted      = var.root_volume_encrypted
  tags                  = local.tags
}

module "dev_pool" {
  source = "../../modules/ec2"

  name_prefix           = "${local.name_prefix}-dev"
  instance_count        = var.dev_pool_count
  ami_id                = data.aws_ami.node.id
  instance_type         = var.dev_pool_instance_type
  subnet_ids            = local.dev_pool_subnet_ids
  security_group_ids    = compact(concat([local.cluster_internal_sg_id, local.worker_sg_id], var.additional_node_security_group_ids))
  key_name              = var.key_pair_name
  instance_profile_name = module.worker_iam.instance_profile_name
  cluster_name          = var.cluster_name
  node_pool             = "dev-pool"
  node_role             = "worker"
  kubernetes_version    = var.kubernetes_version
  kubernetes_channel    = var.kubernetes_channel
  kube_reserved         = var.kube_reserved
  system_reserved       = var.system_reserved
  eviction_hard         = var.eviction_hard
  volume_size           = var.root_volume_size_gib
  volume_type           = var.root_volume_type
  volume_encrypted      = var.root_volume_encrypted
  tags                  = local.tags
}

module "control_plane_internal_nlb" {
  count  = var.enable_control_plane_internal_nlb ? 1 : 0
  source = "../../modules/lb"

  name                  = substr("${local.name_prefix}-cp", 0, 32)
  internal              = true
  load_balancer_type    = "network"
  subnet_ids            = local.private_subnet_ids
  security_group_ids    = []
  listener_port         = 6443
  listener_protocol     = "TCP"
  target_port           = 6443
  target_group_protocol = "TCP"
  target_type           = "instance"
  target_instance_ids   = module.control_plane.instance_ids
  vpc_id                = local.vpc_id
  health_check_protocol = "TCP"
  health_check_port     = "traffic-port"
  tags                  = local.tags
}
