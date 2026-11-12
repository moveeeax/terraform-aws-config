locals {
  # A non-empty exclusion list switches the recorder to the
  # EXCLUSION_BY_RESOURCE_TYPES strategy, which AWS Config only accepts with
  # all_supported = false.
  exclusion_mode = length(var.excluded_resource_types) > 0
  all_supported  = var.all_supported && !local.exclusion_mode
  inclusion_mode = !local.all_supported && !local.exclusion_mode
}

resource "aws_config_configuration_recorder" "this" {
  name     = var.name
  role_arn = var.role_arn

  recording_group {
    all_supported = local.all_supported

    # AWS Config rejects include_global_resource_types unless all_supported is
    # true, and rejects resource_types unless all_supported is false. Send only
    # the field that applies to the selected recording mode. In exclusion mode
    # include_global_resource_types has no effect: global IAM types are
    # recorded unless they are listed in excluded_resource_types.
    include_global_resource_types = local.all_supported ? var.include_global_resource_types : null
    resource_types                = local.inclusion_mode ? var.resource_types : null

    dynamic "exclusion_by_resource_types" {
      for_each = local.exclusion_mode ? [var.excluded_resource_types] : []

      content {
        resource_types = exclusion_by_resource_types.value
      }
    }

    dynamic "recording_strategy" {
      for_each = local.exclusion_mode ? ["EXCLUSION_BY_RESOURCE_TYPES"] : []

      content {
        use_only = recording_strategy.value
      }
    }
  }

  recording_mode {
    recording_frequency = var.recording_frequency

    dynamic "recording_mode_override" {
      for_each = var.recording_mode_overrides

      content {
        description         = recording_mode_override.value.description
        resource_types      = recording_mode_override.value.resource_types
        recording_frequency = recording_mode_override.value.recording_frequency
      }
    }
  }

  lifecycle {
    precondition {
      condition     = !local.exclusion_mode || length(var.resource_types) == 0
      error_message = "resource_types must be empty when excluded_resource_types is set; AWS Config rejects a recording group that both includes and excludes types."
    }

    precondition {
      condition     = !local.inclusion_mode || length(var.resource_types) > 0
      error_message = "resource_types must name at least one resource type when all_supported is false and excluded_resource_types is empty, otherwise the recorder records nothing."
    }

    precondition {
      condition     = !local.all_supported || length(var.resource_types) == 0
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
