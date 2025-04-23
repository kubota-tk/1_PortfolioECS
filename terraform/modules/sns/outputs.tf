##他のモジュールに出力

output "sns_topic_name" {
  value = aws_sns_topic.sns_topic.name
}

