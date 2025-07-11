################################################################################
# EventBridge Scheduler
################################################################################

output "disable_schedule_arn" {
  description = "ARN of the EventBridge schedule for disabling alarms"
  value       = local.create_scheduler ? aws_scheduler_schedule.disable_alarms[0].arn : null
}

output "enable_schedule_arn" {
  description = "ARN of the EventBridge schedule for enabling alarms"
  value       = local.create_scheduler ? aws_scheduler_schedule.enable_alarms[0].arn : null
}

output "scheduler_role_arn" {
  description = "ARN of the IAM role used by EventBridge Scheduler"
  value       = local.create_scheduler ? (var.scheduler_role_arn != null ? var.scheduler_role_arn : aws_iam_role.scheduler[0].arn) : null
}

################################################################################
# CloudWatch Alarm
################################################################################

output "alarm_arns" {
  description = "ARNs of the created CloudWatch alarms"
  value       = var.create_alarms ? { for k, v in aws_cloudwatch_metric_alarm.this : k => v.arn } : {}
}

output "alarm_names" {
  description = "Names of all managed alarms (existing + created)"
  value       = local.create_scheduler ? local.all_alarm_names : []
}

################################################################################
# SNS
################################################################################

output "sns_topic_arn" {
  description = "ARN of the SNS topic"
  value       = var.create_sns_topic || var.existing_sns_topic_arn != null ? local.sns_topic_arn : null
}

output "sns_topic_subscriptions" {
  description = "ARNs of the SNS topic subscriptions"
  value       = var.create_sns_topic ? aws_sns_topic_subscription.email[*].arn : []
}
