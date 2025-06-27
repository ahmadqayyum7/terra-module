

resource "aws_s3_bucket" "frontend" {
  bucket        = "tickup-${var.env}"
  force_destroy = true
  tags = {
    Name        = "TickupFrontend"
    Environment = var.env
  }
}

resource "aws_s3_bucket_public_access_block" "frontend_block" {
  bucket                  = aws_s3_bucket.frontend.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

output "bucket_regional_domain_name" {
  value = aws_s3_bucket.frontend.bucket_regional_domain_name
}
