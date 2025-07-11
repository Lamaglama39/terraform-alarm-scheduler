data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  # Combine existing alarm names and alarm names that will be created by this module
  all_alarm_names = concat(
    var.existing_alarm_names,
    var.create_alarms ? keys(var.alarms) : []
  )

  sns_topic_arn = var.create_sns_topic ? aws_sns_topic.this[0].arn : var.existing_sns_topic_arn

  # Only create EventBridge Scheduler if there are alarms to manage
  create_scheduler = length(local.all_alarm_names) > 0

  alarm_arns = [
    for alarm_name in local.all_alarm_names :
    "arn:aws:cloudwatch:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:alarm:${alarm_name}"
  ]
}

################################################################################
# IAM Role for EventBridge Scheduler
################################################################################

data "aws_iam_policy_document" "scheduler_assume_role" {
  count = local.create_scheduler && var.scheduler_role_arn == null ? 1 : 0

  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "scheduler_policy" {
  count = local.create_scheduler && var.scheduler_role_arn == null ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "cloudwatch:EnableAlarmActions",
      "cloudwatch:DisableAlarmActions"
    ]
    resources = local.alarm_arns
  }
}

resource "aws_iam_role" "scheduler" {
  count = local.create_scheduler && var.scheduler_role_arn == null ? 1 : 0

  name               = "${var.name}-scheduler-role"
  assume_role_policy = data.aws_iam_policy_document.scheduler_assume_role[0].json

  tags = var.tags
}

resource "aws_iam_role_policy" "scheduler" {
  count = local.create_scheduler && var.scheduler_role_arn == null ? 1 : 0

  name   = "${var.name}-scheduler-policy"
  role   = aws_iam_role.scheduler[0].id
  policy = data.aws_iam_policy_document.scheduler_policy[0].json
}

################################################################################
# EventBridge Scheduler
################################################################################

resource "aws_scheduler_schedule" "disable_alarms" {
  count = local.create_scheduler ? 1 : 0

  name        = "${var.name}-disable-alarms"
  description = "Schedule to disable CloudWatch alarms"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression          = var.disable_schedule_expression
  schedule_expression_timezone = var.schedule_timezone

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:cloudwatch:disableAlarmActions"
    role_arn = var.scheduler_role_arn != null ? var.scheduler_role_arn : aws_iam_role.scheduler[0].arn

    input = jsonencode({
      AlarmNames = local.all_alarm_names
    })
  }
}

resource "aws_scheduler_schedule" "enable_alarms" {
  count = local.create_scheduler ? 1 : 0

  name        = "${var.name}-enable-alarms"
  description = "Schedule to enable CloudWatch alarms"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression          = var.enable_schedule_expression
  schedule_expression_timezone = var.schedule_timezone

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:cloudwatch:enableAlarmActions"
    role_arn = var.scheduler_role_arn != null ? var.scheduler_role_arn : aws_iam_role.scheduler[0].arn

    input = jsonencode({
      AlarmNames = local.all_alarm_names
    })
  }
}

################################################################################
# CloudWatch Alarm
################################################################################

resource "aws_cloudwatch_metric_alarm" "this" {
  for_each = var.create_alarms ? var.alarms : {}

  alarm_name          = each.key
  alarm_description   = each.value.alarm_description
  comparison_operator = each.value.comparison_operator
  evaluation_periods  = each.value.evaluation_periods
  metric_name         = each.value.metric_name
  namespace           = each.value.namespace
  period              = each.value.period
  statistic           = each.value.statistic
  threshold           = each.value.threshold

  alarm_actions             = length(each.value.alarm_actions) > 0 ? each.value.alarm_actions : (local.sns_topic_arn != null ? [local.sns_topic_arn] : [])
  ok_actions                = length(each.value.ok_actions) > 0 ? each.value.ok_actions : (local.sns_topic_arn != null ? [local.sns_topic_arn] : [])
  insufficient_data_actions = each.value.insufficient_data_actions

  dimensions          = each.value.dimensions
  unit                = each.value.unit
  datapoints_to_alarm = each.value.datapoints_to_alarm
  treat_missing_data  = each.value.treat_missing_data

  tags = var.tags
}

################################################################################
# SNS
################################################################################

resource "aws_sns_topic" "this" {
  count = var.create_sns_topic ? 1 : 0

  name         = var.sns_topic_name != null ? var.sns_topic_name : "${var.name}-alarms"
  display_name = var.sns_display_name != null ? var.sns_display_name : "${var.name} Alarms"

  tags = var.tags
}

resource "aws_sns_topic_subscription" "email" {
  count = var.create_sns_topic ? length(var.sns_email_addresses) : 0

  topic_arn = aws_sns_topic.this[0].arn
  protocol  = "email"
  endpoint  = var.sns_email_addresses[count.index]
}
