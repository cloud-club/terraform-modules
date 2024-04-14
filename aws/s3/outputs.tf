output "bucket" {
    description = "The S3 bucket"
    value       = aws_s3_bucket.this.bucket
}