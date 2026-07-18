variable "name" {
  description = "Name of the configuration recorder and delivery channel."
  type        = string
  default     = "default"
}

variable "role_arn" {
  description = "ARN of the IAM role AWS Config uses to record and deliver configuration data."
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket that receives configuration snapshots."
  type        = string
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
  description = "Whether to record global resources such as IAM. Only valid when all_supported is true."
  type        = bool
  default     = true
}

variable "delivery_frequency" {
  description = "Frequency at which AWS Config delivers configuration snapshots."
  type        = string
  default     = "TwentyFour_Hours"
}

variable "enable_recorder" {
  description = "Whether the configuration recorder is started."
  type        = bool
  default     = true
}
