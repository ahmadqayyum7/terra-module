provider "aws" {
  region = var.region
}

module "vpc" {
  source = "../../modules/vpc"
}

module "s3" {
  source = "../../modules/s3"
  env    = var.env
}

module "cloudfront" {
  source    = "../../modules/cloudfront"
  env       = var.env
  s3_origin = module.s3.bucket_regional_domain_name
}
