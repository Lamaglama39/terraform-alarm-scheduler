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

module "alarm_scheduler" {
  source  = "Lamaglama39/alarm-scheduler/aws"
  version = "1.0.0"

  name = var.name

  # Create CloudWatch alarms
  create_alarms = true
  alarms        = var.alarms

  # Create SNS topic and subscriptions
  create_sns_topic    = true
  sns_topic_name      = var.sns_topic_name
  sns_display_name    = var.sns_display_name
  sns_email_addresses = var.sns_email_addresses

  # Schedule configuration
  disable_schedule_expression = var.disable_schedule_expression
  enable_schedule_expression  = var.enable_schedule_expression
  schedule_timezone           = var.schedule_timezone

  tags = var.tags
}
