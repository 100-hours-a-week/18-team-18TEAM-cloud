variable "aws_region" {
  description = "AWS region used for remote-state resources."
  type        = string
}

variable "bucket_name" {
  description = "S3 bucket name for Terraform remote state."
  type        = string
}

variable "kms_key_arn" {
  description = "Optional KMS key ARN for state bucket encryption."
  type        = string
  default     = null
}

variable "force_destroy" {
  description = "Whether the state bucket can be force destroyed."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Common tags for remote-state resources."
  type        = map(string)
  default = {
    project   = "bizkit"
    component = "terraform-state"
    managedBy = "terraform"
  }
}
