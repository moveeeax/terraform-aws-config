# terraform-aws-config

Terraform module that manages [AWS
Config](https://aws.amazon.com/config/) recording. It creates a configuration
recorder, a delivery channel that ships snapshots to S3 and a recorder status
resource that starts recording, giving a complete account-level Config setup.

## Usage

```hcl
module "config" {
  source = "github.com/moveeeax/terraform-aws-config"

  name           = "recorder"
  role_arn       = aws_iam_role.config.arn
  s3_bucket_name = "config-snapshots-prod"
}
```

A runnable example lives in [`examples/basic`](examples/basic).

## Requirements

| Name      | Version  |
|-----------|----------|
| terraform | >= 1.5   |
| aws       | >= 5.0   |

## Inputs

| Name                            | Description                                             | Type     | Default              | Required |
|---------------------------------|---------------------------------------------------------|----------|----------------------|:--------:|
| `name`                          | Name of the recorder and delivery channel.              | `string` | `"default"`          |    no    |
| `role_arn`                      | ARN of the Config service role.                         | `string` | n/a                  |   yes    |
| `s3_bucket_name`                | S3 bucket that receives snapshots.                      | `string` | n/a                  |   yes    |
| `s3_key_prefix`                 | Prefix within the S3 bucket.                            | `string` | `null`               |    no    |
| `all_supported`                 | Record all supported resource types.                    | `bool`   | `true`               |    no    |
| `include_global_resource_types` | Record global resources such as IAM.                    | `bool`   | `true`               |    no    |
| `delivery_frequency`            | Snapshot delivery frequency.                            | `string` | `"TwentyFour_Hours"` |    no    |
| `enable_recorder`               | Start the configuration recorder.                       | `bool`   | `true`               |    no    |

## Outputs

| Name                  | Description                                        |
|-----------------------|----------------------------------------------------|
| `recorder_id`         | ID of the configuration recorder.                  |
| `recorder_name`       | Name of the configuration recorder.                |
| `delivery_channel_id` | ID of the delivery channel.                        |
| `recorder_enabled`    | Whether the configuration recorder is enabled.     |

## License

[MIT](LICENSE)
