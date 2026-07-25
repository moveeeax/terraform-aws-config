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

To record a narrower set of resources, turn off `all_supported` and name the
types explicitly:

```hcl
module "config" {
  source = "github.com/moveeeax/terraform-aws-config"

  role_arn       = aws_iam_role.config.arn
  s3_bucket_name = "config-snapshots-prod"

  all_supported  = false
  resource_types = ["AWS::EC2::Instance", "AWS::S3::Bucket"]
}
```

## The S3 bucket

This module does not create the delivery bucket, so the bucket it is pointed at
must be secured by the caller:

- server-side encryption enabled (pass `s3_kms_key_arn` if snapshots should be
  encrypted with a specific customer-managed key);
- public access blocked at the bucket and, ideally, the account level;
- a bucket policy that lets the `config.amazonaws.com` service principal call
  `s3:PutObject` under the delivery prefix and `s3:GetBucketAcl` on the bucket.

Without that policy AWS Config accepts the delivery channel and then silently
fails to deliver snapshots.

## Requirements

| Name      | Version  |
|-----------|----------|
| terraform | >= 1.5   |
| aws       | >= 5.0   |

## Inputs

| Name                            | Description                                                                        | Type           | Default              | Required |
|---------------------------------|------------------------------------------------------------------------------------|----------------|----------------------|:--------:|
| `name`                          | Name of the recorder and delivery channel.                                         | `string`       | `"default"`          |    no    |
| `role_arn`                      | ARN of the Config service role.                                                    | `string`       | n/a                  |   yes    |
| `s3_bucket_name`                | S3 bucket that receives snapshots.                                                 | `string`       | n/a                  |   yes    |
| `s3_key_prefix`                 | Prefix within the S3 bucket.                                                       | `string`       | `null`               |    no    |
| `s3_kms_key_arn`                | KMS key used to encrypt delivered snapshots. Null uses the bucket's own default.   | `string`       | `null`               |    no    |
| `all_supported`                 | Record all supported resource types.                                               | `bool`         | `true`               |    no    |
| `include_global_resource_types` | Record global resources such as IAM. Applied only when `all_supported` is true.    | `bool`         | `true`               |    no    |
| `resource_types`                | Types to record when `all_supported` is false. Must be empty when it is true.      | `list(string)` | `[]`                 |    no    |
| `delivery_frequency`            | Snapshot delivery frequency. One of `One_Hour`, `Three_Hours`, `Six_Hours`, `Twelve_Hours`, `TwentyFour_Hours`. | `string`       | `"TwentyFour_Hours"` |    no    |
| `enable_recorder`               | Start the configuration recorder.                                                  | `bool`         | `true`               |    no    |

## Outputs

| Name                  | Description                                        |
|-----------------------|----------------------------------------------------|
| `recorder_id`         | ID of the configuration recorder.                  |
| `recorder_name`       | Name of the configuration recorder.                |
| `delivery_channel_id` | ID of the delivery channel.                        |
| `recorder_enabled`    | Whether the configuration recorder is enabled.     |

## Tests

The module ships a `terraform test` suite that runs against a mocked AWS
provider, so it needs no credentials and no network:

```sh
terraform init -backend=false
terraform test
```

`mock_provider` requires Terraform (or OpenTofu) 1.7 or newer. That applies to
running the tests only; the module itself still supports the versions listed
under [Requirements](#requirements).

## License

[MIT](LICENSE)
