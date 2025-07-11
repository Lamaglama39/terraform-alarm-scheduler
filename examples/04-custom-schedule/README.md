# Custom Schedule Example

This example demonstrates advanced scheduling patterns with the terraform-alarm-scheduler module, showing how to implement business hours monitoring and other custom schedules.

## What this example creates

- **2 Custom CloudWatch Alarms**:
  - Weekend batch job failure monitoring
  - Business hours API latency monitoring
- **EventBridge Scheduler** with business hours pattern
- **SNS Topic** for notifications
- **IAM Role** for EventBridge Scheduler

## Current Schedule: Business Hours Only

- **Disable alarms**: Every weekday at 6 PM Central Time
- **Enable alarms**: Every weekday at 8 AM Central Time
- **Result**: Alarms are only active Monday-Friday, 8 AM to 6 PM

## Usage

1. **Update the variables** in `variables.tf`:

```hcl
# Update existing alarm names
variable "existing_alarm_names" {
  default = [
    "your-existing-alarm-1",    # ← Change these
    "your-existing-alarm-2"     # ← Change these
  ]
}

# Update resource identifiers in alarms
variable "alarms" {
  default = {
    "business-hours-api-latency" = {
      # ...
      dimensions = {
        FunctionName = "your-actual-function-name"  # ← Change this
      }
    }
  }
}

# Update email addresses
variable "sns_email_addresses" {
  default = [
    "your-team@company.com"     # ← Change this
  ]
}
```

2. **Deploy the infrastructure**:

```bash
terraform init
terraform plan
terraform apply
```

## Custom Schedule Patterns

The example includes several commented schedule patterns you can use. Uncomment and modify the variables in `variables.tf`:

### 1. Maintenance Window Schedule
Disable monitoring during planned maintenance windows:

```hcl
disable_schedule_expression = "cron(0 2 ? * SAT *)"   # 2 AM every Saturday
enable_schedule_expression  = "cron(0 6 ? * SAT *)"   # 6 AM every Saturday
```

### 2. Holiday Schedule
Disable monitoring during holidays:

```hcl
disable_schedule_expression = "cron(0 0 25 12 ? *)"   # Christmas Day
enable_schedule_expression  = "cron(0 0 26 12 ? *)"   # Day after Christmas
```

### 3. Peak Hours Only
Monitor only during high-traffic periods:

```hcl
disable_schedule_expression = "cron(0 22 * * ? *)"    # 10 PM daily
enable_schedule_expression  = "cron(0 10 * * ? *)"    # 10 AM daily
```

### 4. Weekend Monitoring
Monitor only on weekends:

```hcl
disable_schedule_expression = "cron(0 23 ? * SUN *)"  # Sunday 11 PM
enable_schedule_expression  = "cron(0 0 ? * SAT *)"   # Saturday midnight
```

### 5. First Monday of Month
Disable for monthly maintenance:

```hcl
disable_schedule_expression = "cron(0 0 ? * MON#1 *)" # First Monday of month
enable_schedule_expression  = "cron(0 0 ? * TUE#1 *)" # First Tuesday of month
```

## EventBridge Scheduler Cron Format

EventBridge Scheduler uses a 6-field cron format:

```
cron(Minutes Hours Day-of-month Month Day-of-week Year)
```

### Special Characters
- `*` : All values
- `?` : Any value (used in day-of-month or day-of-week)
- `-` : Range (e.g., `MON-FRI`)
- `,` : List (e.g., `MON,WED,FRI`)
- `/` : Step (e.g., `*/5` for every 5 minutes)
- `#` : Nth occurrence (e.g., `MON#1` for first Monday)
- `L` : Last (e.g., `L` for last day of month)

### Examples
- `cron(0 9 * * ? *)` - Every day at 9 AM
- `cron(30 14 ? * MON-FRI *)` - Weekdays at 2:30 PM
- `cron(0 0 1 * ? *)` - First day of every month at midnight
- `cron(0 */4 * * ? *)` - Every 4 hours
- `cron(0 9 ? * MON#1 *)` - First Monday of each month at 9 AM

## Timezone Considerations

The module supports any valid timezone identifier:

- **US Timezones**: `America/New_York`, `America/Chicago`, `America/Denver`, `America/Los_Angeles`
- **European**: `Europe/London`, `Europe/Paris`, `Europe/Berlin`
- **Asian**: `Asia/Tokyo`, `Asia/Singapore`, `Asia/Kolkata`
- **UTC**: `UTC` or `Etc/UTC`

## Use Cases

### 1. Development Environment
Disable monitoring outside business hours to reduce noise:

```hcl
disable_schedule_expression = "cron(0 18 ? * MON-FRI *)"  # 6 PM weekdays
enable_schedule_expression  = "cron(0 8 ? * MON-FRI *)"   # 8 AM weekdays
```

### 2. Batch Processing
Monitor only during batch processing windows:

```hcl
disable_schedule_expression = "cron(0 6 * * ? *)"   # 6 AM daily (batch ends)
enable_schedule_expression  = "cron(0 22 * * ? *)"  # 10 PM daily (batch starts)
```

### 3. Seasonal Business
E-commerce sites might monitor differently during holiday seasons by creating multiple module instances with different schedules.

### 4. Multi-Region
Different regions might have different business hours:

```hcl
# US East Coast
schedule_timezone = "America/New_York"
disable_schedule_expression = "cron(0 18 ? * MON-FRI *)"

# Europe
schedule_timezone = "Europe/London"
disable_schedule_expression = "cron(0 17 ? * MON-FRI *)"  # 5 PM GMT
```

## Best Practices

1. **Test Schedule Expressions**: Use AWS CLI or console to verify your cron expressions
2. **Document Schedules**: Include clear comments about when alarms are active/inactive
3. **Consider Daylight Saving**: Some timezones automatically handle DST transitions
4. **Monitor Schedule Changes**: Use CloudWatch Events to track schedule modifications
5. **Emergency Override**: Keep a manual process to quickly enable alarms if needed

## Outputs

This example includes a `schedule_summary` output that provides a human-readable description of the current schedule configuration.