
##他のモジュールに出力

output "alb_arn_suffix" {
  description = "Alb arn"
  value       = aws_lb.alb.arn_suffix
}

output "alb_id" {
  description = "Alb ID"
  value       = aws_lb.alb.id
}

output "alb_target_arn" {
  description = "Alb Target Arn"
  value       = aws_lb_target_group.alb_target.arn
}

output "alb_target_arn_suffix" {
  description = "Alb Target Arn Suffix"
  value       = aws_lb_target_group.alb_target.arn_suffix
}
