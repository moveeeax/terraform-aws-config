# Test-only requirement: mock_provider needs Terraform >= 1.7 / OpenTofu >= 1.7.
mock_provider "aws" {}

variables {
  role_arn       = "arn:aws:iam::123456789012:role/config"
  s3_bucket_name = "config-snapshots-test"
}

run "rejects_a_recorder_that_records_nothing" {
  command = plan

  variables {
    all_supported  = false
    resource_types = []
  }

  expect_failures = [aws_config_configuration_recorder.this]
}

run "rejects_resource_types_alongside_all_supported" {
  command = plan

  variables {
    all_supported  = true
    resource_types = ["AWS::EC2::Instance"]
  }

  expect_failures = [aws_config_configuration_recorder.this]
}

run "rejects_invalid_delivery_frequency" {
  command = plan

  variables {
    delivery_frequency = "Every_Other_Tuesday"
  }

  expect_failures = [var.delivery_frequency]
}

run "rejects_non_role_arn" {
  command = plan

  variables {
    role_arn = "arn:aws:iam::123456789012:user/not-a-role"
  }

  expect_failures = [var.role_arn]
}

run "rejects_non_kms_key_arn" {
  command = plan

  variables {
    s3_kms_key_arn = "not-an-arn"
  }

  expect_failures = [var.s3_kms_key_arn]
}

run "rejects_empty_name" {
  command = plan

  variables {
    name = ""
  }

  expect_failures = [var.name]
}

run "rejects_resource_types_alongside_excluded_resource_types" {
  command = plan

  variables {
    all_supported           = false
    resource_types          = ["AWS::EC2::Instance"]
    excluded_resource_types = ["AWS::EC2::NetworkInterface"]
  }

  expect_failures = [aws_config_configuration_recorder.this]
}

run "rejects_invalid_recording_frequency" {
  command = plan

  variables {
    recording_frequency = "HOURLY"
  }

  expect_failures = [var.recording_frequency]
}

run "rejects_more_than_one_recording_mode_override" {
  command = plan

  variables {
    recording_mode_overrides = [
      { resource_types = ["AWS::EC2::NetworkInterface"], recording_frequency = "DAILY" },
      { resource_types = ["AWS::EC2::Instance"], recording_frequency = "DAILY" },
    ]
  }

  expect_failures = [var.recording_mode_overrides]
}

run "rejects_recording_mode_override_without_resource_types" {
  command = plan

  variables {
    recording_mode_overrides = [{ resource_types = [], recording_frequency = "DAILY" }]
  }

  expect_failures = [var.recording_mode_overrides]
}

run "rejects_invalid_recording_mode_override_frequency" {
  command = plan

  variables {
    recording_mode_overrides = [{ resource_types = ["AWS::EC2::NetworkInterface"], recording_frequency = "WEEKLY" }]
  }

  expect_failures = [var.recording_mode_overrides]
}

run "rejects_daily_override_for_config_compliance_types" {
  command = plan

  variables {
    recording_mode_overrides = [{ resource_types = ["AWS::Config::ResourceCompliance"], recording_frequency = "DAILY" }]
  }

  expect_failures = [var.recording_mode_overrides]
}
