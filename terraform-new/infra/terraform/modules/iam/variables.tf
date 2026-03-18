variable "role_name" {
  description = "IAM role name for EC2 nodes."
  type        = string
}

variable "instance_profile_name" {
  description = "IAM instance profile name for EC2 nodes."
  type        = string
}

variable "create_instance_profile" {
  description = "Whether to create and manage an IAM instance profile for the role."
  type        = bool
  default     = true
}

variable "additional_managed_policy_arns" {
  description = "Optional managed policy ARNs attached to the role."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags applied to IAM resources."
  type        = map(string)
  default     = {}
}
