variable "bucket_name" {
  description = "S3 bucket name for Terraform state."
  type        = string
}

variable "kms_key_arn" {
  description = "Optional KMS key ARN for S3 state bucket encryption."
  type        = string
  default     = null
}

variable "force_destroy" {
  description = "Whether to allow force destroy on the state bucket."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Common tags applied to remote-state resources."
  type        = map(string)
  default     = {}
}
