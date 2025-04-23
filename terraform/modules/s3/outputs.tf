##他のモジュールに出力

output "s3_app_storage_id" {
  description = "S3 Bucket ID"
  value       = aws_s3_bucket.app_storage_bucket.id
}


