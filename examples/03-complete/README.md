# Complete Example

This example demonstrates the full capabilities of the terraform-alarm-scheduler module, including creating CloudWatch alarms, SNS topic, and scheduling.

## What this example creates

- **4 CloudWatch Alarms**:
  - High CPU utilization (EC2)
  - High memory utilization (CloudWatch Agent)
  - Low disk space (CloudWatch Agent)
  - High error rate (Lambda)
- **SNS Topic** with email subscriptions
- **EventBridge Scheduler** rules to disable/enable all alarms
- **IAM Role** for EventBridge Scheduler

## Schedule

- **Disable alarms**: Every day at 8 PM Eastern Time
- **Enable alarms**: Every day at 8 AM Eastern Time

## Usage

1. **Update the variables** in `variables.tf` to match your environment:

```hcl
# Update instance IDs, function names, etc.
variable "alarms" {
  default = {
    "high-cpu" = {
      # ...
      dimensions = {
        InstanceId = "i-your-actual-instance-id"  # ← Change this
      }
    }
    "lambda-error-rate" = {
      # ...
      dimensions = {
        FunctionName = "your-actual-function-name"  # ← Change this
      }
    }
  }
}

# Update email addresses
variable "sns_email_addresses" {
  default = [
    "your-email@company.com",     # ← Change this
    "team-alerts@company.com"     # ← Change this
  ]
}
```

2. **Deploy the infrastructure**:

```bash
terraform init
terraform plan
terraform apply
```

3. **Confirm email subscriptions**: Check your email and confirm the SNS subscriptions.

## Alarm Details

### High CPU Alarm
- **Metric**: `CPUUtilization` from `AWS/EC2`
- **Threshold**: 80%
- **Evaluation**: 2 periods of 5 minutes

### High Memory Alarm
- **Metric**: `MemoryUtilization` from `CWAgent`
- **Threshold**: 85%
- **Evaluation**: 2 periods of 5 minutes
- **Requires**: CloudWatch Agent installed on EC2

### Low Disk Space Alarm
- **Metric**: `disk_used_percent` from `CWAgent`
- **Threshold**: Less than 20% free
- **Evaluation**: 1 period of 5 minutes
- **Requires**: CloudWatch Agent installed on EC2

### Lambda Error Rate Alarm
- **Metric**: `Errors` from `AWS/Lambda`
- **Threshold**: More than 5 errors
- **Evaluation**: 2 periods of 5 minutes

## Prerequisites

### For EC2 Alarms
- EC2 instances must exist with the specified instance IDs
- For memory and disk metrics, CloudWatch Agent must be installed and configured

### For Lambda Alarms
- Lambda functions must exist with the specified function names

## Customization

### Changing the Schedule
Modify the schedule expressions in `variables.tf`:

```hcl
# Business hours only (Monday-Friday)
disable_schedule_expression = "cron(0 18 ? * MON-FRI *)"  # 6 PM weekdays
enable_schedule_expression  = "cron(0 9 ? * MON-FRI *)"   # 9 AM weekdays

# Different timezone
schedule_timezone = "Asia/Tokyo"
```

### Adding More Alarms
Add more alarms to the `alarms` variable:

```hcl
variable "alarms" {
  default = {
    # ... existing alarms ...
    
    "api-gateway-4xx" = {
      alarm_description   = "High 4xx error rate"
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 2
      metric_name         = "4XXError"
      namespace           = "AWS/ApiGateway"
      period              = 300
      statistic           = "Sum"
      threshold           = 10
      dimensions = {
        ApiName = "my-api"
      }
    }
  }
}
```

## Outputs

This example provides comprehensive outputs for monitoring and integration:

- Schedule ARNs for both enable/disable operations
- All created alarm ARNs and names
- SNS topic ARN and subscription ARNs
- IAM role ARN

## Cost Considerations

This example creates:
- 4 CloudWatch alarms (~$0.40/month)
- 1 SNS topic with 2 email subscriptions (minimal cost)
- EventBridge Scheduler rules (minimal cost)

Total estimated cost: ~$0.50/month (may vary by region)