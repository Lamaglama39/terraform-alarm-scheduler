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
  source = "Lamaglama39/alarm-scheduler/aws"

  name = var.name

  existing_alarm_names = var.existing_alarm_names

  disable_schedule_expression = var.disable_schedule_expression
  enable_schedule_expression  = var.enable_schedule_expression
  schedule_timezone           = var.schedule_timezone

  tags = var.tags
}
