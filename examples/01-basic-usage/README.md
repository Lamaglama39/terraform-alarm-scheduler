# Basic Usage Example

This example demonstrates the basic usage of the terraform-alarm-scheduler module with existing CloudWatch alarms.

## What this example does

- Creates EventBridge Scheduler rules to disable/enable existing CloudWatch alarms
- Disables alarms at 10 PM JST daily
- Enables alarms at 6 AM JST daily
- Uses a list of predefined alarm names

## Usage

1. Update the `existing_alarm_names` variable with your actual alarm names:

```hcl
variable "existing_alarm_names" {
  description = "List of existing CloudWatch alarm names to schedule"
  type        = list(string)
  default = [
    "your-actual-alarm-1",
    "your-actual-alarm-2",
    "your-actual-alarm-3"
  ]
}
```

2. Deploy the infrastructure:

```bash
terraform init
terraform plan
terraform apply
```

## Configuration

### Schedule

- **Disable**: Every day at 22:00 (Asia/Tokyo)
- **Enable**: Every day at 06:00 (Asia/Tokyo)

### Prerequisites

- Existing CloudWatch alarms must already exist in your AWS account
- Ensure the alarm names in `existing_alarm_names` match exactly

### Customization

You can customize the schedule by modifying:

- `disable_schedule_expression`: Change when alarms are disabled
- `enable_schedule_expression`: Change when alarms are enabled
- `schedule_timezone`: Change the timezone

Example for business hours only (Monday-Friday):

```hcl
disable_schedule_expression = "cron(0 18 ? * MON-FRI *)"  # 6 PM on weekdays
enable_schedule_expression  = "cron(0 9 ? * MON-FRI *)"   # 9 AM on weekdays
```

## Outputs

This example provides the following outputs:

- `disable_schedule_arn`: ARN of the schedule that disables alarms
- `enable_schedule_arn`: ARN of the schedule that enables alarms
- `scheduler_role_arn`: ARN of the IAM role used by EventBridge Scheduler
- `alarm_names`: List of all managed alarm names