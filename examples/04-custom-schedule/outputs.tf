output "disable_schedule_arn" {
  description = "ARN of the EventBridge schedule for disabling alarms"
  value       = module.alarm_scheduler.disable_schedule_arn
}

output "enable_schedule_arn" {
  description = "ARN of the EventBridge schedule for enabling alarms"
  value       = module.alarm_scheduler.enable_schedule_arn
}

output "scheduler_role_arn" {
  description = "ARN of the IAM role used by EventBridge Scheduler"
  value       = module.alarm_scheduler.scheduler_role_arn
}

output "alarm_arns" {
  description = "ARNs of the created CloudWatch alarms"
  value       = module.alarm_scheduler.alarm_arns
}

output "alarm_names" {
  description = "Names of all managed alarms (existing + created)"
  value       = module.alarm_scheduler.alarm_names
}

output "sns_topic_arn" {
  description = "ARN of the created SNS topic"
  value       = module.alarm_scheduler.sns_topic_arn
}

output "schedule_summary" {
  description = "Summary of the custom schedule configuration"
  value = {
    disable_time = var.disable_schedule_expression
    enable_time  = var.enable_schedule_expression
    timezone     = var.schedule_timezone
    description  = "Business hours monitoring: Alarms active 8 AM - 6 PM weekdays (Central Time)"
  }
}