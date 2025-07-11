variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

variable "name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "existing-sns-example"
}

variable "existing_sns_topic_arn" {
  description = "ARN of an existing SNS topic to use for alarm notifications"
  type        = string
  default = "arn:aws:sns:ap-northeast-1:123456789012:existing-alerts-topic" # Replace with your SNS topic ARN
}

variable "alarms" {
  description = "Map of CloudWatch alarms to create"
  type = map(object({
    alarm_description         = optional(string, "")
    comparison_operator       = string
    evaluation_periods        = number
    metric_name               = string
    namespace                 = string
    period                    = number
    statistic                 = string
    threshold                 = number
    alarm_actions             = optional(list(string), [])
    ok_actions                = optional(list(string), [])
    insufficient_data_actions = optional(list(string), [])
    dimensions                = optional(map(string), {})
    unit                      = optional(string, null)
    datapoints_to_alarm       = optional(number, null)
    treat_missing_data        = optional(string, "missing")
  }))
  default = {
    "ec2-status-check-failed" = {
      alarm_description   = "EC2 instance status check failed"
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 2
      metric_name         = "StatusCheckFailed"
      namespace           = "AWS/EC2"
      period              = 60
      statistic           = "Maximum"
      threshold           = 0
      dimensions = {
        InstanceId = "i-XXXXXXXXXXXXXXXXX" # Replace with your EC2 instance ID
      }
      treat_missing_data = "missing"
    }
    "ec2-instance-status-check-failed" = {
      alarm_description   = "EC2 instance status check failed (instance level)"
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 2
      metric_name         = "StatusCheckFailed_Instance"
      namespace           = "AWS/EC2"
      period              = 60
      statistic           = "Maximum"
      threshold           = 0
      dimensions = {
        InstanceId = "i-XXXXXXXXXXXXXXXXX" # Replace with your EC2 instance ID
      }
      treat_missing_data = "missing"
    }
    "ec2-system-status-check-failed" = {
      alarm_description   = "EC2 system status check failed (AWS infrastructure level)"
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 2
      metric_name         = "StatusCheckFailed_System"
      namespace           = "AWS/EC2"
      period              = 60
      statistic           = "Maximum"
      threshold           = 0
      dimensions = {
        InstanceId = "i-XXXXXXXXXXXXXXXXX" # Replace with your EC2 instance ID
      }
      treat_missing_data = "missing"
    }
    "ec2-cpu-high" = {
      alarm_description   = "High CPU utilization on EC2 instance"
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 5
      metric_name         = "CPUUtilization"
      namespace           = "AWS/EC2"
      period              = 60
      statistic           = "Average"
      threshold           = 80
      dimensions = {
        InstanceId = "i-XXXXXXXXXXXXXXXXX" # Replace with your EC2 instance ID
      }
      treat_missing_data = "missing"
    }
  }
}

variable "disable_schedule_expression" {
  description = "Schedule expression for disabling alarms (cron format)"
  type        = string
  default     = "cron(0 19 * * ? *)" # 7 PM daily
}

variable "enable_schedule_expression" {
  description = "Schedule expression for enabling alarms (cron format)"
  type        = string
  default     = "cron(0 7 * * ? *)" # 7 AM daily
}

variable "schedule_timezone" {
  description = "Timezone for the schedule"
  type        = string
  default     = "Asia/Tokyo"
}

variable "tags" {
  description = "A map of tags to assign to all resources"
  type        = map(string)
  default = {
    Environment = "production"
    Project     = "monitoring"
    Example     = "existing-sns"
    Team        = "platform"
  }
}
