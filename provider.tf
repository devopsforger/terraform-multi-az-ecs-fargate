terraform {
  required_version = ">= 1.14.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.31.0"
    }
  }

  backend "s3" {
    encrypt      = true
    use_lockfile = true
  }
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

# Configure the AWS Provider
provider "aws" {
  region  = var.aws_region
  profile = "devopsforge"
}