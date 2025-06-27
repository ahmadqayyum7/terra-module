variable "region" {
  description = "AWS region"
  default     = "eu-west-2"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "azs" {
  description = "Availability Zones"
  type        = list(string)
  default     = ["eu-west-2a", "eu-west-2b"]
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {
    Project = "LondonVPCSetup"
    Owner   = "Ahmad"
  }
}

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

# -------------------------------
# VPC
# -------------------------------
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge(var.tags, { Name = "London-VPC-prod" })
}

# -------------------------------
# Public Subnets
# -------------------------------
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true
  tags                    = merge(var.tags, { Name = "Public-${var.azs[count.index]}" })
}

# -------------------------------
# Private Subnets
# -------------------------------
resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.azs[count.index]
  tags              = merge(var.tags, { Name = "Private-${var.azs[count.index]}" })
}

# -------------------------------
# Internet Gateway
# -------------------------------
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags   = merge(var.tags, { Name = "IGW" })
}

# -------------------------------
# Public Route Table & Routes
# -------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags   = merge(var.tags, { Name = "Public-RT" })
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# -------------------------------
# Private Route Table
# -------------------------------
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags   = merge(var.tags, { Name = "Private-RT" })
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# -------------------------------
# Security Group for Interface Endpoint
# -------------------------------
resource "aws_security_group" "endpoint_sg" {
  name        = "vpc-endpoint-sg"
  description = "Allow HTTPS traffic for Interface Endpoints"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "EndpointSG" })
}

# -------------------------------
# SQS Interface VPC Endpoint
# -------------------------------
resource "aws_vpc_endpoint" "sqs" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.sqs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.endpoint_sg.id]
  private_dns_enabled = true
  tags                = merge(var.tags, { Name = "SQS-Endpoint" })
}

# -------------------------------
# DynamoDB Gateway VPC Endpoint
# -------------------------------
resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private.id]
  tags              = merge(var.tags, { Name = "DynamoDB-Endpoint" })
}

# -------------------------------
# Outputs
# -------------------------------
output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}
