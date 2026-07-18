output "recorder_id" {
  description = "ID of the configuration recorder."
  value       = aws_config_configuration_recorder.this.id
}

output "recorder_name" {
  description = "Name of the configuration recorder."
  value       = aws_config_configuration_recorder.this.name
}

output "delivery_channel_id" {
  description = "ID of the delivery channel."
  value       = aws_config_delivery_channel.this.id
}

output "recorder_enabled" {
  description = "Whether the configuration recorder is enabled."
  value       = aws_config_configuration_recorder_status.this.is_enabled
}
