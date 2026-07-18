terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

variable "region" {
  description = "AWS region for the provider."
  type        = string
  default     = "us-east-1"
}

variable "config_role_arn" {
  description = "ARN of the AWS Config service role."
  type        = string
}

variable "config_bucket_name" {
  description = "Name of the S3 bucket for configuration snapshots."
  type        = string
}

provider "aws" {
  region = var.region
}

module "config" {
  source = "../.."

  name           = "example-recorder"
  role_arn       = var.config_role_arn
  s3_bucket_name = var.config_bucket_name
}

output "recorder_name" {
  value = module.config.recorder_name
}
