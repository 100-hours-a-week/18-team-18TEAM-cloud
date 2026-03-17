output "bucket_name" {
  value       = aws_s3_bucket.this.bucket
  description = "Remote state S3 bucket name."
}
