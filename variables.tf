variable "name" {
  description = "Name of the configuration recorder and delivery channel."
  type        = string
  default     = "default"
}

variable "role_arn" {
  description = "ARN of the IAM role AWS Config uses to record and deliver configuration data."
  type        = string

  validation {
    condition     = can(regex("^arn:[a-z0-9-]+:iam::[0-9]{12}:role/", var.role_arn))
    error_message = "role_arn must be an IAM role ARN, for example arn:aws:iam::123456789012:role/config."
  }
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket that receives configuration snapshots. The bucket should have server-side encryption enabled, public access blocked and a policy that allows the AWS Config service principal to write."
  type        = string

  validation {
    condition     = length(var.s3_bucket_name) > 0
    error_message = "s3_bucket_name must not be empty."
  }
}

variable "s3_key_prefix" {
  description = "Prefix within the S3 bucket for delivered objects. Null delivers to the bucket root."
  type        = string
  default     = null
}

variable "all_supported" {
  description = "Whether to record configuration changes for all supported resource types."
  type        = bool
  default     = true
}

variable "include_global_resource_types" {
  description = "Whether to record global resources such as IAM. Only applied when all_supported is true; ignored otherwise."
  type        = bool
  default     = true
}

variable "resource_types" {
  description = "Resource types to record when all_supported is false, for example [\"AWS::EC2::Instance\"]. Must be empty when all_supported is true."
  type        = list(string)
  default     = []
}

variable "s3_kms_key_arn" {
  description = "ARN of a KMS key used to encrypt configuration snapshots delivered to S3. Null falls back to the bucket's own default encryption."
  type        = string
  default     = null

  validation {
    condition     = var.s3_kms_key_arn == null || can(regex("^arn:[a-z0-9-]+:kms:", var.s3_kms_key_arn))
    error_message = "s3_kms_key_arn must be a KMS key ARN, for example arn:aws:kms:us-east-1:123456789012:key/<id>."
  }
}

variable "delivery_frequency" {
  description = "Frequency at which AWS Config delivers configuration snapshots."
  type        = string
  default     = "TwentyFour_Hours"

  validation {
    condition = contains([
      "One_Hour",
      "Three_Hours",
      "Six_Hours",
      "Twelve_Hours",
      "TwentyFour_Hours",
    ], var.delivery_frequency)
    error_message = "delivery_frequency must be one of One_Hour, Three_Hours, Six_Hours, Twelve_Hours or TwentyFour_Hours."
  }
}

variable "enable_recorder" {
  description = "Whether the configuration recorder is started."
  type        = bool
  default     = true
}
