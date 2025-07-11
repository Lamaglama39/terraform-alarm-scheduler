variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

variable "name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "basic-example"
}

variable "existing_alarm_names" {
  description = "List of existing CloudWatch alarm names to schedule"
  type        = list(string)
  default = [
    "high-cpu-alarm",
    "high-memory-alarm",
    "disk-space-low"
  ]
}

variable "disable_schedule_expression" {
  description = "Schedule expression for disabling alarms (cron format)"
  type        = string
  default     = "cron(0 22 * * ? *)"
}

variable "enable_schedule_expression" {
  description = "Schedule expression for enabling alarms (cron format)"
  type        = string
  default     = "cron(0 6 * * ? *)"
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
    Environment = "example"
    Project     = "alarm-scheduler"
    Example     = "basic-usage"
  }
}
