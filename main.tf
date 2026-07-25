resource "aws_config_configuration_recorder" "this" {
  name     = var.name
  role_arn = var.role_arn

  recording_group {
    all_supported = var.all_supported

    # AWS Config rejects include_global_resource_types unless all_supported is
    # true, and rejects resource_types unless all_supported is false. Send only
    # the field that applies to the selected recording mode.
    include_global_resource_types = var.all_supported ? var.include_global_resource_types : null
    resource_types                = var.all_supported ? null : var.resource_types
  }

  lifecycle {
    precondition {
      condition     = var.all_supported || length(var.resource_types) > 0
      error_message = "resource_types must name at least one resource type when all_supported is false, otherwise the recorder records nothing."
    }

    precondition {
      condition     = !var.all_supported || length(var.resource_types) == 0
      error_message = "resource_types must be empty when all_supported is true; AWS Config rejects a recording group that sets both."
    }
  }
}

resource "aws_config_delivery_channel" "this" {
  name           = var.name
  s3_bucket_name = var.s3_bucket_name
  s3_key_prefix  = var.s3_key_prefix
  s3_kms_key_arn = var.s3_kms_key_arn

  snapshot_delivery_properties {
    delivery_frequency = var.delivery_frequency
  }

  depends_on = [aws_config_configuration_recorder.this]
}

resource "aws_config_configuration_recorder_status" "this" {
  name       = aws_config_configuration_recorder.this.name
  is_enabled = var.enable_recorder

  depends_on = [aws_config_delivery_channel.this]
}
