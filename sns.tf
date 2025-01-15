resource "aws_sns_topic" "Ec2-Right-Sizing-SNS" {
  name = var.sns-topic-name

  tags = var.tags
}

resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  topic_arn = aws_sns_topic.Ec2-Right-Sizing-SNS.arn
  protocol  = "email"
  endpoint  = var.email-topic-subscription
}
