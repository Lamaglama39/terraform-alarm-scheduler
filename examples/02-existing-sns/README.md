# Existing SNS Topic Example

This example demonstrates using the terraform-alarm-scheduler module with an existing SNS topic for notifications.

## What this example creates

- **3 CloudWatch Alarms**:
  - RDS CPU utilization
  - RDS database connections
  - Application Load Balancer response time
- **EventBridge Scheduler** rules to disable/enable all alarms
- **IAM Role** for EventBridge Scheduler

## What this example uses

- **Existing SNS Topic**: The module will use your existing SNS topic for alarm notifications

## Schedule

- **Disable alarms**: Every day at 7 PM London Time
- **Enable alarms**: Every day at 7 AM London Time

## Usage

1. **Update the SNS topic ARN** in `variables.tf`:

```hcl
variable "existing_sns_topic_arn" {
  description = "ARN of an existing SNS topic to use for alarm notifications"
  type        = string
  default     = "arn:aws:sns:us-west-2:123456789012:your-existing-topic"  # ← Change this
}
```

2. **Update resource identifiers** in the `alarms` variable:

```hcl
variable "alarms" {
  default = {
    "rds-cpu-high" = {
      # ...
      dimensions = {
        DBInstanceIdentifier = "your-actual-db-instance"  # ← Change this
      }
    }
    "elb-latency-high" = {
      # ...
      dimensions = {
        LoadBalancer = "app/your-load-balancer/1234567890abcdef"  # ← Change this
      }
    }
  }
}
```

3. **Deploy the infrastructure**:

```bash
terraform init
terraform plan
terraform apply
```

## Alarm Details

### RDS CPU High
- **Metric**: `CPUUtilization` from `AWS/RDS`
- **Threshold**: 80%
- **Evaluation**: 2 periods of 5 minutes

### RDS Connections High
- **Metric**: `DatabaseConnections` from `AWS/RDS`
- **Threshold**: 50 connections
- **Evaluation**: 2 periods of 5 minutes

### ELB Latency High
- **Metric**: `TargetResponseTime` from `AWS/ApplicationELB`
- **Threshold**: 2.0 seconds
- **Evaluation**: 2 periods of 5 minutes

## Prerequisites

### SNS Topic
- An existing SNS topic must exist in your AWS account
- The SNS topic should have appropriate subscriptions (email, SMS, etc.) already configured
- Ensure the SNS topic is in the same region as your other resources

### AWS Resources
- **RDS Database**: Must exist with the specified DB instance identifier
- **Application Load Balancer**: Must exist with the specified load balancer ARN

## Finding Resource Identifiers

### RDS Database Instance Identifier
```bash
aws rds describe-db-instances --query 'DBInstances[*].[DBInstanceIdentifier]' --output table
```

### Application Load Balancer ARN
```bash
aws elbv2 describe-load-balancers --query 'LoadBalancers[*].[LoadBalancerName,LoadBalancerArn]' --output table
```

The LoadBalancer dimension format for ALB is: `app/{name}/{id}`

### SNS Topic ARN
```bash
aws sns list-topics --query 'Topics[*].TopicArn' --output table
```

## Benefits of Using Existing SNS Topic

- **Centralized Notifications**: Use your existing notification infrastructure
- **Consistent Alerting**: All alerts go to the same channels your team already monitors
- **Cost Optimization**: No additional SNS topics or subscriptions needed
- **Easier Management**: Single point of configuration for notification preferences

## Customization

### Adding More AWS Services

You can add alarms for other AWS services:

```hcl
# CloudFront distribution
"cloudfront-4xx-errors" = {
  alarm_description   = "High 4xx error rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "4xxErrorRate"
  namespace           = "AWS/CloudFront"
  period              = 300
  statistic           = "Average"
  threshold           = 5
  dimensions = {
    DistributionId = "E1234567890ABC"
  }
}

# DynamoDB table
"dynamodb-throttles" = {
  alarm_description   = "DynamoDB throttling events"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ThrottledRequests"
  namespace           = "AWS/DynamoDB"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  dimensions = {
    TableName = "my-table"
  }
}
```

## Outputs

This example provides outputs for monitoring and integration, including the existing SNS topic ARN being used.