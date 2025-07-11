# terraform-alarm-scheduler

A Terraform module for creating CloudWatch alarm schedulers using EventBridge Scheduler. This module allows you to automatically enable and disable CloudWatch alarms based on schedules, creating pseudo-maintenance windows for monitoring exclusion periods.

## Features

- **EventBridge Scheduler**: Automatically enable/disable CloudWatch alarms on schedule
- **CloudWatch Alarms**: Optional creation of CloudWatch metric alarms
- **SNS Integration**: Optional SNS topic creation with email subscriptions
- **Flexible Configuration**: Support for existing resources or module-managed resources
- **Timezone Support**: Configure schedules in any timezone
- **Least Privilege IAM**: Automatically scoped permissions to specific alarms and regions
- **Comprehensive Examples**: 4 examples covering different use cases

## Usage

### Basic Usage with Existing Alarms

```hcl
module "alarm_scheduler" {
  source  = "Lamaglama39/alarm-scheduler/aws"
  version = "1.0.0"
  
  name = "my-app"
  
  existing_alarm_names = [
    "high-cpu-alarm",
    "high-memory-alarm"
  ]
  
  # Disable alarms at 10 PM JST, enable at 6 AM JST
  disable_schedule_expression = "cron(0 22 * * ? *)"
  enable_schedule_expression  = "cron(0 6 * * ? *)"
  schedule_timezone          = "Asia/Tokyo"
  
  tags = {
    Environment = "production"
    Team        = "platform"
  }
}
```

### EC2 Comprehensive Monitoring with SNS Topic

```hcl
module "alarm_scheduler" {
  source  = "Lamaglama39/alarm-scheduler/aws"
  version = "1.0.0"
  
  name = "my-app"
  
  # Create EC2 monitoring alarms
  create_alarms = true
  alarms = {
    "ec2-status-check-failed" = {
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 2
      metric_name        = "StatusCheckFailed"
      namespace          = "AWS/EC2"
      period             = 60
      statistic          = "Maximum"
      threshold          = 0
      alarm_description  = "EC2 instance status check failed"
      dimensions = {
        InstanceId = "i-1234567890abcdef0"
      }
      treat_missing_data = "breaching"
    }
    "ec2-cpu-high" = {
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 5
      metric_name        = "CPUUtilization"
      namespace          = "AWS/EC2"
      period             = 60
      statistic          = "Average"
      threshold          = 80
      alarm_description  = "High CPU utilization on EC2 instance"
      dimensions = {
        InstanceId = "i-1234567890abcdef0"
      }
      treat_missing_data = "missing"
    }
  }
  
  # Create SNS topic
  create_sns_topic = true
  sns_email_addresses = [
    "alerts@example.com",
    "oncall@example.com"
  ]
  
  tags = {
    Environment = "production"
  }
}
```

### Business Hours Monitoring (Weekdays Only)

```hcl
module "alarm_scheduler" {
  source  = "Lamaglama39/alarm-scheduler/aws"
  version = "1.0.0"
  
  name = "business-monitoring"
  
  # Mix existing and new alarms
  existing_alarm_names = ["existing-app-errors"]
  
  create_alarms = true
  alarms = {
    "ec2-status-check-failed" = {
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 2
      metric_name        = "StatusCheckFailed"
      namespace          = "AWS/EC2"
      period             = 60
      statistic          = "Maximum"
      threshold          = 0
      alarm_description  = "EC2 instance death monitoring"
      dimensions = {
        InstanceId = "i-1234567890abcdef0"
      }
      treat_missing_data = "breaching"
    }
  }
  
  # Business hours only: 8 AM - 6 PM JST, weekdays
  disable_schedule_expression = "cron(0 18 ? * MON-FRI *)"
  enable_schedule_expression  = "cron(0 8 ? * MON-FRI *)"
  schedule_timezone          = "Asia/Tokyo"
  
  # Use existing SNS topic
  existing_sns_topic_arn = "arn:aws:sns:ap-northeast-1:123456789012:existing-topic"
  
  tags = {
    Environment = "production"
    Schedule    = "business-hours"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 6.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 6.0 |

## Examples

This module includes 4 comprehensive examples in the `examples/` directory:

1. **[01-basic-usage](./examples/01-basic-usage/)** - Schedule existing alarms (minimal setup)
2. **[02-existing-sns](./examples/02-existing-sns/)** - EC2 monitoring with existing SNS topic
3. **[03-complete](./examples/03-complete/)** - Full implementation with new SNS topic
4. **[04-custom-schedule](./examples/04-custom-schedule/)** - Business hours patterns

All examples are configured for **ap-northeast-1** region and **Asia/Tokyo** timezone.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name prefix for all resources | `string` | n/a | yes |
| tags | A map of tags to assign to all resources | `map(string)` | `{}` | no |
| schedule_timezone | Timezone for the schedule (e.g., Asia/Tokyo, UTC) | `string` | `"UTC"` | no |
| disable_schedule_expression | Schedule expression for disabling alarms (cron format) | `string` | `"cron(0 22 * * ? *)"` | no |
| enable_schedule_expression | Schedule expression for enabling alarms (cron format) | `string` | `"cron(0 6 * * ? *)"` | no |
| existing_alarm_names | List of existing CloudWatch alarm names to schedule | `list(string)` | `[]` | no |
| scheduler_role_arn | ARN of the IAM role for EventBridge Scheduler. If not provided, a role will be created | `string` | `null` | no |
| create_alarms | Whether to create CloudWatch alarms | `bool` | `false` | no |
| alarms | Map of CloudWatch alarms to create (see Alarm Object below) | `map(object)` | `{}` | no |
| create_sns_topic | Whether to create an SNS topic | `bool` | `false` | no |
| sns_topic_name | Name of the SNS topic to create | `string` | `null` | no |
| sns_display_name | Display name for the SNS topic | `string` | `null` | no |
| sns_email_addresses | List of email addresses to subscribe to the SNS topic | `list(string)` | `[]` | no |
| existing_sns_topic_arn | ARN of an existing SNS topic to use for alarm notifications | `string` | `null` | no |

### Alarm Object

The `alarms` variable accepts a map of alarm objects with the following structure:

```hcl
alarms = {
  "alarm-name" = {
    alarm_description         = optional(string, "")           # Description for the alarm
    comparison_operator       = string                         # GreaterThanThreshold, LessThanThreshold, etc.
    evaluation_periods        = number                         # Number of periods to evaluate
    metric_name              = string                          # CloudWatch metric name
    namespace                = string                          # AWS service namespace (e.g., AWS/EC2)
    period                   = number                          # Period in seconds
    statistic                = string                          # Average, Sum, Maximum, etc.
    threshold                = number                          # Threshold value
    alarm_actions            = optional(list(string), [])     # SNS topic ARNs for alarm state
    ok_actions               = optional(list(string), [])     # SNS topic ARNs for OK state
    insufficient_data_actions = optional(list(string), [])    # SNS topic ARNs for insufficient data
    dimensions               = optional(map(string), {})      # Metric dimensions (e.g., InstanceId)
    unit                     = optional(string, null)         # Metric unit
    datapoints_to_alarm      = optional(number, null)         # Number of datapoints that must breach
    treat_missing_data       = optional(string, "missing")    # How to treat missing data
  }
}
```

## Outputs

| Name | Description |
|------|-------------|
| disable_schedule_arn | ARN of the EventBridge schedule for disabling alarms (null if no alarms) |
| enable_schedule_arn | ARN of the EventBridge schedule for enabling alarms (null if no alarms) |
| scheduler_role_arn | ARN of the IAM role used by EventBridge Scheduler (null if no alarms) |
| alarm_arns | Map of alarm names to ARNs for created CloudWatch alarms (empty map if not creating alarms) |
| alarm_names | List of all managed alarm names - existing + created (empty list if no alarms) |
| sns_topic_arn | ARN of the SNS topic (null if not using SNS) |
| sns_topic_subscriptions | List of SNS topic subscription ARNs (empty list if not creating SNS topic) |

## Schedule Expressions

The module uses EventBridge Scheduler with cron expressions. Here are some common patterns:

- `cron(0 22 * * ? *)` - Every day at 10:00 PM
- `cron(0 6 * * ? *)` - Every day at 6:00 AM
- `cron(0 18 ? * FRI *)` - Every Friday at 6:00 PM
- `cron(0 9 ? * MON *)` - Every Monday at 9:00 AM

## IAM Permissions

The module automatically creates an IAM role for EventBridge Scheduler with **least privilege permissions**:

- `cloudwatch:EnableAlarmActions` - scoped to specific alarm ARNs
- `cloudwatch:DisableAlarmActions` - scoped to specific alarm ARNs

**Key Security Features**:
- Permissions limited to specific alarms (not `*`)
- Automatically scoped to current AWS account and region
- Only works on alarms managed by this module instance

Example generated policy:
```json
{
  "Effect": "Allow",
  "Action": [
    "cloudwatch:EnableAlarmActions",
    "cloudwatch:DisableAlarmActions"
  ],
  "Resource": [
    "arn:aws:cloudwatch:ap-northeast-1:123456789012:alarm:ec2-status-check-failed",
    "arn:aws:cloudwatch:ap-northeast-1:123456789012:alarm:ec2-cpu-high"
  ]
}
```

If you provide your own IAM role via `scheduler_role_arn`, ensure it has appropriate permissions.

## License

This module is released under the MIT License. See LICENSE for more information.
