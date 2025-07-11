# Examples

This directory contains comprehensive examples demonstrating different usage patterns of the terraform-alarm-scheduler module.

## Available Examples

### 1. [01-basic-usage](./01-basic-usage/)
**Use Case**: Schedule existing CloudWatch alarms

- Uses existing CloudWatch alarms only
- Simple on/off scheduling (22:00-06:00 JST)
- Minimal configuration - no new resources created
- Perfect for getting started

**Best for**: Teams with existing monitoring infrastructure who want to add scheduling

### 2. [02-existing-sns](./02-existing-sns/)
**Use Case**: EC2 comprehensive monitoring with existing SNS

- Creates **4 EC2 CloudWatch alarms**:
  - StatusCheckFailed (general death monitoring)
  - StatusCheckFailed_Instance (OS/software issues)
  - StatusCheckFailed_System (AWS infrastructure issues)
  - CPUUtilization (performance monitoring)
- Uses existing SNS topic for notifications
- Schedule: 19:00-07:00 JST (12-hour off period)
- Focus on EC2 instance health monitoring

**Best for**: Teams with established notification channels who need EC2 monitoring

### 3. [03-complete](./03-complete/)
**Use Case**: Full-featured implementation with everything included

- Creates **4 EC2 CloudWatch alarms** (same as existing-sns example)
- Creates SNS topic with email subscriptions
- Schedule: 20:00-08:00 JST (12-hour off period)
- Complete monitoring setup from scratch

**Best for**: New monitoring setups or comprehensive examples

### 4. [04-custom-schedule](./04-custom-schedule/)
**Use Case**: Advanced scheduling patterns with mixed resources

- **Mixed approach**: 2 existing alarms + 4 new EC2 alarms
- Business hours monitoring (18:00-08:00 weekdays only)
- Complex cron expressions with detailed examples
- Multiple schedule pattern examples in comments

**Best for**: Organizations with specific operational windows and business hours requirements

## Quick Start

Choose the example that best matches your use case:

```bash
# Clone and navigate to an example
cd examples/basic-usage

# Customize variables
cp variables.tf my-variables.tf
# Edit my-variables.tf with your settings

# Deploy
terraform init
terraform plan -var-file="my-variables.tf"
terraform apply -var-file="my-variables.tf"
```

## Common Configuration Patterns

### Schedule Expressions

All examples use EventBridge Scheduler cron format:

```
cron(Minutes Hours Day-of-month Month Day-of-week Year)
```

**Common Patterns**:
- `cron(0 22 * * ? *)` - Every day at 10 PM
- `cron(0 8 ? * MON-FRI *)` - Weekdays at 8 AM
- `cron(0 18 ? * FRI *)` - Every Friday at 6 PM
- `cron(0 0 1 * ? *)` - First day of each month

### Timezone Support

Specify any valid timezone:

```hcl
schedule_timezone = "Asia/Tokyo"        # Japan Standard Time
schedule_timezone = "America/New_York"  # Eastern Time
schedule_timezone = "Europe/London"     # Greenwich Mean Time
schedule_timezone = "UTC"               # Coordinated Universal Time
```

### Tags

All examples include consistent tagging:

```hcl
tags = {
  Environment = "production"
  Project     = "monitoring"
  Example     = "basic-usage"
  ManagedBy   = "terraform"
}
```

## Comparison Matrix

| Feature | 01-basic-usage | 02-existing-sns | 03-complete | 04-custom-schedule |
|---------|----------------|-----------------|-------------|-------------------|
| **Alarms Created** | ❌ None | ✅ 4 EC2 alarms | ✅ 4 EC2 alarms | ✅ 4 EC2 alarms |
| **Existing Alarms** | ✅ 3 alarms | ❌ None | ❌ None | ✅ 2 alarms |
| **SNS Topic** | ❌ Not created | ❌ Uses existing | ✅ Creates new | ✅ Creates new |
| **Email Setup** | ❌ No emails | ✅ Uses existing | ✅ 2 addresses | ✅ 2 addresses |
| **Schedule** | 22:00-06:00 JST | 19:00-07:00 JST | 20:00-08:00 JST | 18:00-08:00 (weekdays) |
| **Monitoring Type** | Generic | EC2 focused | EC2 focused | EC2 + existing |
| **Complexity** | Very Low | Medium | Medium | High |
| **Region** | ap-northeast-1 | ap-northeast-1 | ap-northeast-1 | ap-northeast-1 |

## Detailed Alarm Breakdown

### EC2 Alarms (02, 03, 04 examples)
All EC2-focused examples include the same 4 comprehensive alarms:

1. **ec2-status-check-failed**: General instance health (any failure)
2. **ec2-instance-status-check-failed**: OS/software level issues
3. **ec2-system-status-check-failed**: AWS infrastructure issues  
4. **ec2-cpu-high**: CPU utilization > 80% (5 periods × 1 minute)

## Prerequisites

### General Requirements

- Terraform >= 1.0
- AWS Provider >= 6.0
- AWS CLI configured with appropriate permissions

### Permissions Required

The examples require the following AWS permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "cloudwatch:*",
        "events:*",
        "scheduler:*",
        "sns:*",
        "iam:*"
      ],
      "Resource": "*"
    }
  ]
}
```

For production use, consider more restrictive permissions.

## Customization Guidelines

### 1. Update EC2 Instance IDs

**Important**: Replace placeholder instance IDs in examples 02, 03, and 04:

```hcl
# In variables.tf, update all dimensions
dimensions = {
  InstanceId = "i-XXXXXXXXXXXXXXXXX"  # ← Replace with your actual EC2 instance ID
}
```

Find your instance ID:
```bash
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,Tags[?Key==`Name`].Value|[0]]' --output table
```

### 2. Update SNS Configuration

**For examples 02-existing-sns**: Update with your existing SNS topic ARN:
```hcl
existing_sns_topic_arn = "arn:aws:sns:ap-northeast-1:YOUR-ACCOUNT:your-topic"
```

**For examples 03-complete and 04-custom-schedule**: Update email addresses:
```hcl
sns_email_addresses = [
  "alerts@yourcompany.com",      # ← Your email
  "oncall@yourcompany.com"       # ← Your on-call email
]
```

### 3. Verify Region and Timezone

All examples are pre-configured for:
- **Region**: `ap-northeast-1` (Tokyo)
- **Timezone**: `Asia/Tokyo` (JST)

Change if needed:
```hcl
aws_region = "ap-northeast-1"        # ← Change if needed
schedule_timezone = "Asia/Tokyo"     # ← Change if needed
```

## Testing

### Validate Configuration

```bash
terraform validate
terraform plan
```

### Test Schedule Expressions

Use AWS CLI to validate cron expressions:

```bash
aws events put-rule \
  --name test-rule \
  --schedule-expression "cron(0 8 ? * MON-FRI *)" \
  --state DISABLED

aws events delete-rule --name test-rule
```

### Manual Testing

Test alarm enable/disable manually:

```bash
# Disable alarms
aws cloudwatch disable-alarm-actions --alarm-names "your-alarm-name"

# Enable alarms
aws cloudwatch enable-alarm-actions --alarm-names "your-alarm-name"
```

## Troubleshooting

### Common Issues

1. **Invalid cron expression**: Use EventBridge format, not standard cron
2. **Wrong timezone**: Use `aws events describe-rule` to verify
3. **Missing permissions**: Check IAM role for EventBridge Scheduler
4. **Alarm not found**: Verify alarm names exist in CloudWatch

### Debug Commands

```bash
# List schedules
aws scheduler list-schedules

# Describe specific schedule
aws scheduler get-schedule --name "your-schedule-name"

# Check alarm status
aws cloudwatch describe-alarms --alarm-names "your-alarm-name"
```

## Contributing

When adding new examples:

1. Follow the established directory structure
2. Include comprehensive README
3. Add meaningful variable descriptions
4. Include multiple use case variations
5. Test thoroughly before submitting