variable "env" {
  description = "Environment name (e.g., dev, prod)"
  default     = "dev"
}

resource "aws_s3_bucket" "frontend" {
  bucket        = "tickup-frontend-dev-ahmadqayyum123"
  force_destroy = true
  tags = {
    Name        = "FrontendHosting"
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

output "bucket_name" {
  value = aws_s3_bucket.frontend.id
}

output "bucket_regional_domain_name" {
  value = aws_s3_bucket.frontend.bucket_regional_domain_name
}
