# Test-only requirement: mock_provider needs Terraform >= 1.7 / OpenTofu >= 1.7.
# The module itself still supports the required_version declared in versions.tf.
mock_provider "aws" {}

variables {
  role_arn       = "arn:aws:iam::123456789012:role/config"
  s3_bucket_name = "config-snapshots-test"
}

run "records_everything_by_default" {
  assert {
    condition     = aws_config_configuration_recorder.this.recording_group[0].all_supported
    error_message = "The recorder must record all supported resource types by default."
  }

  assert {
    condition     = aws_config_configuration_recorder.this.recording_group[0].include_global_resource_types
    error_message = "The recorder must record global resource types such as IAM by default."
  }

  assert {
    condition     = length(coalesce(aws_config_configuration_recorder.this.recording_group[0].resource_types, [])) == 0
    error_message = "resource_types must not be sent alongside all_supported."
  }
}

run "recorder_is_started_by_default" {
  assert {
    condition     = aws_config_configuration_recorder_status.this.is_enabled
    error_message = "A recorder that is never started records nothing; it must be enabled by default."
  }
}

run "delivers_snapshots_daily_by_default" {
  assert {
    condition     = aws_config_delivery_channel.this.snapshot_delivery_properties[0].delivery_frequency == "TwentyFour_Hours"
    error_message = "Default snapshot delivery frequency must be TwentyFour_Hours."
  }
}

run "global_resource_types_are_dropped_when_not_recording_everything" {
  variables {
    all_supported  = false
    resource_types = ["AWS::EC2::Instance"]
  }

  # include_global_resource_types keeps its default of true, and AWS Config
  # rejects it unless all_supported is true, so the module must drop it.
  assert {
    condition     = coalesce(aws_config_configuration_recorder.this.recording_group[0].include_global_resource_types, false) == false
    error_message = "include_global_resource_types must not be sent when all_supported is false."
  }

  assert {
    condition     = aws_config_configuration_recorder.this.recording_group[0].resource_types == toset(["AWS::EC2::Instance"])
    error_message = "resource_types must be forwarded to the recording group when all_supported is false."
  }
}

run "kms_key_is_forwarded_to_the_delivery_channel" {
  variables {
    s3_kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/00000000-1111-2222-3333-444444444444"
  }

  assert {
    condition     = aws_config_delivery_channel.this.s3_kms_key_arn == "arn:aws:kms:us-east-1:123456789012:key/00000000-1111-2222-3333-444444444444"
    error_message = "s3_kms_key_arn must be forwarded so snapshots are encrypted with the given key."
  }
}
