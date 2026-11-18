resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "assessment" {
  bucket = "${var.project_name}-${random_id.bucket_suffix.hex}"

  force_destroy = false

  tags = {
    Project     = "AWS Cloud Security Assessment"
    Environment = "Test"
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket_public_access_block" "assessment" {
  bucket = aws_s3_bucket.assessment.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "assessment" {
  bucket = aws_s3_bucket.assessment.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "assessment" {
  bucket = aws_s3_bucket.assessment.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "assessment" {
  bucket = aws_s3_bucket.assessment.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}
