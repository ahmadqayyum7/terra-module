variable "region" {
  description = "AWS region"
  default     = "eu-west-2"
}

variable "env" {
  description = "Environment name"
  default     = "prod"
}

variable "bucket_name" {
  description = "Custom name for the S3 bucket"
  default     = "tickup-frontend-prod-ahmadqayyum123"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  type        = list(string)
  description = "CIDR blocks for public subnets"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  type        = list(string)
  description = "CIDR blocks for private subnets"
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "azs" {
  type        = list(string)
  description = "Availability Zones"
  default     = ["eu-west-2a", "eu-west-2b"]
}

variable "tags" {
  type = map(string)
  default = {
    Project = "TickupInfra"
    Owner   = "Ahmad"
  }
}
