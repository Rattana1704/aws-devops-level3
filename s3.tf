resource "aws_s3_bucket" "terraform_state" {
  bucket        = "rattana-rueanmoon-apl-tfstate-573535109120-20261118123946"
  force_destroy = false

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Team        = "APL"
    ManagedBy   = "terraform"
    Environment = var.ec2_name
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
