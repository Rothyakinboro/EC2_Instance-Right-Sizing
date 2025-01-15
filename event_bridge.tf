resource "aws_scheduler_schedule" "Ec2-Right_Size-Trigger" {
  name = var.event_scheduler
    group_name = "default"
  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = "rate(1 day)"

  target {
    arn      = aws_lambda_function.Ec2-Right-Size-lambda.arn
    role_arn = aws_iam_role.event-bridge-role.arn
  }
}

