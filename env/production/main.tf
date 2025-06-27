terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.region
}



module "vpc" {
  source        = "../../modules/vpc"
  region        = var.region
  vpc_cidr      = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  azs           = var.azs
  tags          = var.tags
  env           = var.env
}

module "s3" {
  source = "../../modules/s3"
  env    = var.env
  bucket_name = var.bucket_name
}

module "cloudfront" {
  source     = "../../modules/cloudfront"
  env        = var.env
  s3_origin  = module.s3.bucket_regional_domain_name
}
