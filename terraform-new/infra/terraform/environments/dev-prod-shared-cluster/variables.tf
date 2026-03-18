variable "aws_region" {
  description = "AWS region for the shared cluster."
  type        = string
}

variable "project_name" {
  description = "Project prefix used for naming."
  type        = string
}

variable "environment_name" {
  description = "Environment label for the shared cluster scaffold."
  type        = string
  default     = "shared"
}

variable "cluster_name" {
  description = "kubeadm cluster name."
  type        = string
}

variable "cluster_endpoint_dns_name" {
  description = "Stable DNS name used as kubeadm controlPlaneEndpoint."
  type        = string
}

variable "create_vpc" {
  description = "Whether Terraform should create a new VPC and subnets. Set false to reuse existing network."
  type        = bool
  default     = false
}

variable "existing_vpc_id" {
  description = "Existing VPC ID used when create_vpc is false."
  type        = string
  default     = null
}

variable "existing_public_subnet_ids" {
  description = "Existing public subnet IDs used when create_vpc is false. Optional for current scope but useful for future ALB/NAT references."
  type        = list(string)
  default     = []
}

variable "existing_private_subnet_ids" {
  description = "Existing private subnet IDs used when create_vpc is false. These subnets host control plane and worker nodes."
  type        = list(string)
  default     = []
}

variable "control_plane_subnet_ids" {
  description = "Optional subnet IDs dedicated to control plane placement. Defaults to existing_private_subnet_ids or created private subnets."
  type        = list(string)
  default     = []
}

variable "app_pool_subnet_ids" {
  description = "Optional subnet IDs dedicated to app-pool placement. Defaults to existing_private_subnet_ids or created private subnets."
  type        = list(string)
  default     = []
}

variable "ai_serving_pool_subnet_ids" {
  description = "Optional subnet IDs dedicated to ai-serving-pool placement. Defaults to existing_private_subnet_ids or created private subnets."
  type        = list(string)
  default     = []
}

variable "system_pool_subnet_ids" {
  description = "Optional subnet IDs dedicated to system-pool placement. Defaults to existing_private_subnet_ids or created private subnets."
  type        = list(string)
  default     = []
}

variable "availability_zones" {
  description = "AZ list for the shared cluster VPC when create_vpc is true."
  type        = list(string)
  default     = []
}

variable "vpc_cidr" {
  description = "VPC CIDR block when create_vpc is true."
  type        = string
  default     = null
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs, one per AZ, used when create_vpc is true."
  type        = list(string)
  default     = []
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs, one per AZ, used when create_vpc is true."
  type        = list(string)
  default     = []
}

variable "enable_nat_gateway" {
  description = "Whether NAT Gateway resources are created."
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Whether a single NAT Gateway is used across all private subnets."
  type        = bool
  default     = true
}

variable "allowed_ssh_cidrs" {
  description = "Allowed CIDRs for SSH access. Do not use 0.0.0.0/0."
  type        = list(string)
  default     = []
}

variable "allowed_ssh_security_group_ids" {
  description = "Security groups such as VPN or Bastion SG that can reach SSH."
  type        = list(string)
  default     = []
}

variable "allowed_control_plane_api_cidrs" {
  description = "Allowed CIDRs for kube-apiserver 6443 access."
  type        = list(string)
  default     = []
}

variable "allowed_control_plane_api_security_group_ids" {
  description = "Security groups that can reach kube-apiserver 6443."
  type        = list(string)
  default     = []
}

variable "ingress_source_cidrs" {
  description = "Future ALB or restricted source CIDRs for HAProxy NodePort access."
  type        = list(string)
  default     = []
}

variable "ingress_source_security_group_ids" {
  description = "Future ALB SG IDs allowed to reach worker ingress NodePorts."
  type        = list(string)
  default     = []
}

variable "key_pair_name" {
  description = "EC2 key pair name used for SSH."
  type        = string
}

variable "existing_cluster_internal_security_group_id" {
  description = "Optional existing cluster-internal SG ID to reuse."
  type        = string
  default     = null
}

variable "existing_control_plane_security_group_id" {
  description = "Optional existing control-plane SG ID to reuse."
  type        = string
  default     = null
}

variable "existing_worker_security_group_id" {
  description = "Optional existing worker SG ID to reuse."
  type        = string
  default     = null
}

variable "additional_node_security_group_ids" {
  description = "Optional security group IDs attached to every cluster node in addition to the cluster SGs."
  type        = list(string)
  default     = []
}

variable "create_instance_profiles" {
  description = "Whether Terraform should create IAM instance profiles for EC2 nodes. Disable if the caller lacks iam:CreateInstanceProfile."
  type        = bool
  default     = true
}

variable "control_plane_instance_type" {
  description = "EC2 instance type for control plane."
  type        = string
  default     = "t4g.medium"
}

variable "app_pool_instance_type" {
  description = "EC2 instance type for app-pool."
  type        = string
  default     = "t4g.large"
}

variable "ai_serving_pool_instance_type" {
  description = "EC2 instance type for ai-serving-pool."
  type        = string
  default     = "t4g.large"
}

variable "system_pool_instance_type" {
  description = "EC2 instance type for system-pool."
  type        = string
  default     = "t4g.large"
}

variable "control_plane_count" {
  description = "Initial control plane count."
  type        = number
  default     = 1
}

variable "app_pool_count" {
  description = "Initial app-pool node count."
  type        = number
  default     = 2
}

variable "ai_serving_pool_count" {
  description = "Initial ai-serving-pool node count."
  type        = number
  default     = 1
}

variable "system_pool_count" {
  description = "Initial system-pool node count."
  type        = number
  default     = 1
}

variable "root_volume_size_gib" {
  description = "Root EBS size in GiB for all nodes."
  type        = number
  default     = 60
}

variable "root_volume_type" {
  description = "Root EBS type for all nodes."
  type        = string
  default     = "gp3"
}

variable "root_volume_encrypted" {
  description = "Whether root EBS is encrypted."
  type        = bool
  default     = true
}

variable "ami_owners" {
  description = "AMI owners used for the Ubuntu ARM64 lookup."
  type        = list(string)
  default     = ["099720109477"]
}

variable "ami_name_pattern" {
  description = "AMI name pattern used to select the node image."
  type        = string
}

variable "ami_architecture" {
  description = "AMI architecture."
  type        = string
  default     = "arm64"
}

variable "kubernetes_version" {
  description = "Full Kubernetes version used by kubeadm."
  type        = string
  default     = "v1.33.9"
}

variable "kubernetes_channel" {
  description = "Kubernetes apt channel used by node bootstrap."
  type        = string
  default     = "v1.33"
}

variable "kube_reserved" {
  description = "kubelet kubeReserved setting."
  type        = string
  default     = "cpu=150m,memory=400Mi,ephemeral-storage=1Gi"
}

variable "system_reserved" {
  description = "kubelet systemReserved setting."
  type        = string
  default     = "cpu=150m,memory=600Mi,ephemeral-storage=1Gi"
}

variable "eviction_hard" {
  description = "kubelet evictionHard setting."
  type        = string
  default     = "memory.available<500Mi,nodefs.available<10%,imagefs.available<15%,nodefs.inodesFree<5%"
}

variable "service_subnet" {
  description = "Kubernetes Service CIDR."
  type        = string
  default     = "10.96.0.0/12"
}

variable "pod_subnet" {
  description = "Kubernetes Pod CIDR."
  type        = string
  default     = "10.244.0.0/16"
}

variable "enable_control_plane_internal_nlb" {
  description = "Whether to provision an internal NLB for the future controlPlaneEndpoint."
  type        = bool
  default     = false
}

variable "control_plane_additional_policy_arns" {
  description = "Optional managed policies attached to the control plane IAM role."
  type        = list(string)
  default     = []
}

variable "worker_additional_policy_arns" {
  description = "Optional managed policies attached to the worker IAM role."
  type        = list(string)
  default     = []
}

variable "default_tags" {
  description = "Default tags applied to all resources."
  type        = map(string)
  default     = {}
}
