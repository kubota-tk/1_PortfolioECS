##他のモジュールに出力したいもの

output "ecs-sg-id" {
  description = "ECSSecurityGroup ID"
  value       = aws_security_group.ecs_security_group.id
}

output "rds-sg-id" {
  description = "RDSSecurityGroup ID"
  value       = aws_security_group.rds_security_group.id
}

output "alb-sg-id" {
  description = "ALBSecurityGroup ID"
  value       = aws_security_group.alb_security_group.id
}

output "ec2-sg-id" {
  description = "EC2SecurityGroup ID"
  value       = aws_security_group.ec2_security_group.id
}
