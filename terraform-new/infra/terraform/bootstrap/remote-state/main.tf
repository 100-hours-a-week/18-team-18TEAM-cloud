provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.tags
  }
}

module "remote_state" {
  source = "../../modules/remote-state"

  bucket_name   = var.bucket_name
  kms_key_arn   = var.kms_key_arn
  force_destroy = var.force_destroy
  tags          = var.tags
}
