######## トピック ########
resource "aws_sns_topic" "sns_topic" {
  name = join("-", [var.environment_identifier, "topic"])
  tags = {
    Name = "${var.project_name}-topic"
  }
}

######## サブスクリプション ########
resource "aws_sns_topic_subscription" "sns_topic_target" {
  topic_arn = aws_sns_topic.sns_topic.arn
  protocol  = "email"
  endpoint  = var.email
}
