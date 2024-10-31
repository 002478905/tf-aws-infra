resource "aws_s3_bucket" "bucket" {
  bucket = "${uuid()}"
  force_destroy = true  # allows Terraform to delete the bucket, even if it contains objects
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


resource "aws_s3_bucket_lifecycle_configuration" "bucket_lifecycle" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    id     = "lifecycle_rule"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}
