output "bucket_name" {
  value       = module.remote_state.bucket_name
  description = "Terraform state S3 bucket name."
}
