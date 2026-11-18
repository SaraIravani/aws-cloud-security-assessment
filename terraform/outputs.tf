output "assessment_bucket_name" {
  description = "Name of the test S3 bucket"
  value       = aws_s3_bucket.assessment.bucket
}

output "assessment_bucket_arn" {
  description = "ARN of the test S3 bucket"
  value       = aws_s3_bucket.assessment.arn
}

output "aws_region" {
  value = var.aws_region
}
