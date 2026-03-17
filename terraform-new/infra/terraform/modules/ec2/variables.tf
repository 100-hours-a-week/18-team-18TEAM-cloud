variable "name_prefix" {
  description = "Instance name prefix."
  type        = string
}

variable "instance_count" {
  description = "Number of EC2 instances to create."
  type        = number
}

variable "ami_id" {
  description = "AMI ID used for EC2 instances."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs used for round-robin placement."
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security groups attached to the instances."
  type        = list(string)
}

variable "key_name" {
  description = "EC2 key pair name used for SSH."
  type        = string
  default     = null
}

variable "instance_profile_name" {
  description = "IAM instance profile attached to the EC2 instances."
  type        = string
  default     = null
}

variable "cluster_name" {
  description = "Cluster name used for tagging and bootstrap."
  type        = string
}

variable "node_pool" {
  description = "Logical node pool name."
  type        = string
}

variable "node_role" {
  description = "Node role used for tagging and bootstrap."
  type        = string
}

variable "kubernetes_version" {
  description = "Full Kubernetes version string used by kubeadm."
  type        = string
}

variable "kubernetes_channel" {
  description = "Kubernetes apt repo channel such as v1.33."
  type        = string
  default     = "v1.33"
}

variable "kube_reserved" {
  description = "kubelet kubeReserved defaults."
  type        = string
}

variable "system_reserved" {
  description = "kubelet systemReserved defaults."
  type        = string
}

variable "eviction_hard" {
  description = "kubelet evictionHard defaults."
  type        = string
}

variable "volume_size" {
  description = "Root volume size in GiB."
  type        = number
  default     = 60
}

variable "volume_type" {
  description = "Root volume type."
  type        = string
  default     = "gp3"
}

variable "volume_encrypted" {
  description = "Whether to encrypt the root volume."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to the EC2 instances."
  type        = map(string)
  default     = {}
}
