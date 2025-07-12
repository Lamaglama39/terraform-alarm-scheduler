terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Example showing custom scheduling patterns for different use cases
module "alarm_scheduler" {
  source = "Lamaglama39/alarm-scheduler/aws"

  name = var.name

  # Mix of existing alarms and created alarms
  existing_alarm_names = var.existing_alarm_names
  create_alarms        = true
  alarms               = var.alarms

  # Custom schedule configuration
  disable_schedule_expression = var.disable_schedule_expression
  enable_schedule_expression  = var.enable_schedule_expression
  schedule_timezone           = var.schedule_timezone

  # Create SNS topic for notifications
  create_sns_topic    = true
  sns_topic_name      = "${var.name}-custom-schedule-alerts"
  sns_display_name    = "Custom Schedule Alarm Notifications"
  sns_email_addresses = var.sns_email_addresses

  tags = var.tags
}
