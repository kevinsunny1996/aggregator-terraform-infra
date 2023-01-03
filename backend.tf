# S3 bucket to store TFState files in encrypted form without state locking
resource "aws_s3_bucket" "terraform_backend" {
  bucket        = "aggregator-infra-state"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "terraform_versioning" {
  bucket = aws_s3_bucket.terraform_backend.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_encrypt" {
  bucket = aws_s3_bucket.terraform_backend.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}