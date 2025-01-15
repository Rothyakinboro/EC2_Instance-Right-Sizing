resource "aws_iam_role" "lambda_role" {
  name               = "Ec2-right-sizing-lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role_lambda.json
}

resource "aws_iam_policy" "lambda-policy" {
  name        = "Ec2-right-sizing-lambda-policy"
  description = "A policy to allow lambda right size Ec2"
  policy      = data.aws_iam_policy_document.policy.json
}

resource "aws_iam_role_policy_attachment" "Ec2-right-sizing-lambda-attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda-policy.arn
}

resource "aws_iam_policy" "event-bridge-policy" {
  name        = "Ec2-Right-Size-Event-Trigger"
  description = "Policy that allows event bridge to trigger lambda"
  policy      = data.aws_iam_policy_document.event_bridge_policy.json
}

resource "aws_iam_role" "event-bridge-role" {
  name               = "Ec2-Right-Size-Event-Trigger-Role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_event_bridge.json
}

resource "aws_iam_role_policy_attachment" "event-bridge-attach" {
  role       = aws_iam_role.event-bridge-role.name
  policy_arn = aws_iam_policy.event-bridge-policy.arn
}

/*
resource "aws_iam_role" "event-bridge-scheduler-role" {
  name = "Ec2-Right-Size-Scheduler-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "scheduler.amazonaws.com"  # EventBridge Scheduler needs to assume this role
        }
      }
    ]
  })
}

resource "aws_iam_policy" "event-bridge-policy" {
  name        = "Ec2-Right-Size-Event-Trigger-Policy"
  description = "Policy to allow EventBridge Scheduler to trigger Lambda"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "lambda:InvokeFunction"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "event-bridge-scheduler-attach" {
  role       = aws_iam_role.event-bridge-scheduler-role.name
  policy_arn = aws_iam_policy.event-bridge-policy.arn
}
*/