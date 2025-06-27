output "vpc_id" {
  description = "The ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "s3_bucket_url" {
  description = "S3 bucket regional domain name"
  value       = module.s3.bucket_regional_domain_name
}

output "cloudfront_url" {
  description = "CloudFront distribution domain name"
  value       = module.cloudfront.domain_name
}
