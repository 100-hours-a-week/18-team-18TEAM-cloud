variable "name" {
  description = "Name tag for the NAT instance."
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the NAT instance."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for the NAT instance."
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where the NAT instance is deployed."
  type        = string
}

variable "security_group_ids" {
  description = "Security group IDs attached to the NAT instance."
  type        = list(string)
}

variable "key_name" {
  description = "SSH key pair name for the NAT instance."
  type        = string
}

variable "iam_instance_profile_name" {
  description = "IAM instance profile name attached to the NAT instance."
  type        = string
  default     = null
}

variable "associate_public_ip_address" {
  description = "Whether to associate a public IP on instance launch."
  type        = bool
  default     = true
}

variable "source_dest_check" {
  description = "Whether source/destination check is enabled."
  type        = bool
  default     = false
}

variable "instance_tags" {
  description = "Additional tags for NAT instance."
  type        = map(string)
  default     = {}
}

variable "eip_tags" {
  description = "Additional tags for Elastic IP."
  type        = map(string)
  default     = {}
}
