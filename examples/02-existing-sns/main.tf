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

# Example of creating alarms that use an existing SNS topic
module "alarm_scheduler" {
  source = "Lamaglama39/alarm-scheduler/aws"

  name = var.name

  # Create CloudWatch alarms
  create_alarms = true
  alarms        = var.alarms

  # Use existing SNS topic
  existing_sns_topic_arn = var.existing_sns_topic_arn

  # Schedule configuration
  disable_schedule_expression = var.disable_schedule_expression
  enable_schedule_expression  = var.enable_schedule_expression
  schedule_timezone           = var.schedule_timezone

  tags = var.tags
}
