variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

variable "name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "custom-schedule-example"
}

variable "existing_alarm_names" {
  description = "List of existing CloudWatch alarm names to schedule"
  type        = list(string)
  default = [
    "existing-app-errors",
    "existing-database-lag"
  ]
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

# Business hours schedule: Disable monitoring during off-hours (6 PM - 8 AM, weekends)
variable "disable_schedule_expression" {
  description = "Schedule expression for disabling alarms (cron format)"
  type        = string
  default     = "cron(0 18 ? * MON-FRI *)" # 6 PM on weekdays
}

variable "enable_schedule_expression" {
  description = "Schedule expression for enabling alarms (cron format)"
  type        = string
  default     = "cron(0 8 ? * MON-FRI *)" # 8 AM on weekdays
}

variable "schedule_timezone" {
  description = "Timezone for the schedule"
  type        = string
  default     = "Asia/Tokyo"
}

variable "sns_email_addresses" {
  description = "List of email addresses to subscribe to the SNS topic"
  type        = list(string)
  default = [
    "example_1@example.com",
    "example_2@example.com"
  ]
}

variable "tags" {
  description = "A map of tags to assign to all resources"
  type        = map(string)
  default = {
    Environment  = "production"
    Project      = "monitoring"
    Example      = "custom-schedule"
    ScheduleType = "business-hours"
    Owner        = "platform-team"
  }
}

# Alternative schedule examples (commented out)
# Uncomment and modify the disable/enable expressions above to use these patterns

# Maintenance window schedule: Disable during planned maintenance
# variable "disable_schedule_expression" {
#   default = "cron(0 2 ? * SAT *)"   # 2 AM every Saturday
# }
# variable "enable_schedule_expression" {
#   default = "cron(0 6 ? * SAT *)"   # 6 AM every Saturday
# }

# Holiday schedule: Disable during specific dates
# variable "disable_schedule_expression" {
#   default = "cron(0 0 25 12 ? *)"   # Christmas Day
# }
# variable "enable_schedule_expression" {
#   default = "cron(0 0 26 12 ? *)"   # Day after Christmas
# }

# Peak hours only: Monitor only during high-traffic periods
# variable "disable_schedule_expression" {
#   default = "cron(0 22 * * ? *)"    # 10 PM daily
# }
# variable "enable_schedule_expression" {
#   default = "cron(0 10 * * ? *)"    # 10 AM daily
# }
