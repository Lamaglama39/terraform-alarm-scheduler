################################################################################
# General
################################################################################

variable "name" {
  description = "Name prefix for all resources"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to all resources"
  type        = map(string)
  default     = {}
}

################################################################################
# EventBridge Scheduler
################################################################################

variable "schedule_timezone" {
  description = "Timezone for the schedule (e.g., Asia/Tokyo, UTC)"
  type        = string
  default     = "UTC"
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

variable "existing_alarm_names" {
  description = "List of existing CloudWatch alarm names to schedule"
  type        = list(string)
  default     = []
}

variable "scheduler_role_arn" {
  description = "ARN of the IAM role for EventBridge Scheduler. If not provided, a role will be created"
  type        = string
  default     = null
}

################################################################################
# CloudWatch Alarm
################################################################################

variable "create_alarms" {
  description = "Whether to create CloudWatch alarms"
  type        = bool
  default     = false
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
  default = {}
}

################################################################################
# SNS
################################################################################

variable "create_sns_topic" {
  description = "Whether to create an SNS topic"
  type        = bool
  default     = false
}

variable "sns_topic_name" {
  description = "Name of the SNS topic to create"
  type        = string
  default     = null
}

variable "sns_display_name" {
  description = "Display name for the SNS topic"
  type        = string
  default     = null
}

variable "sns_email_addresses" {
  description = "List of email addresses to subscribe to the SNS topic"
  type        = list(string)
  default     = []
}

variable "existing_sns_topic_arn" {
  description = "ARN of an existing SNS topic to use for alarm notifications"
  type        = string
  default     = null
}
