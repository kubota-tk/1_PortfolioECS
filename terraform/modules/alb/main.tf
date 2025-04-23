######## alb ########
resource "aws_lb" "alb" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb-sg-id]
  subnets            = [var.pub_sub_1_id, var.pub_sub_2_id]
  ip_address_type    = "ipv4"

  tags = {
    Name = "${var.project_name}-alb"
  }
}

######## ターゲットグループ ########
resource "aws_lb_target_group" "alb_target" {
  name               = "${var.project_name}-alb-tg"
  vpc_id             = var.vpc_id
  port               = "80"
  protocol           = "HTTP"
  ip_address_type    = "ipv4"
  protocol_version   = "HTTP1"
  target_type        = "ip"
  health_check {
    port = 80      ##コンテナへの死活監視
    path = "/"
  }
  tags = {
    Name = "${var.project_name}-alb-tg"
  }
}

##アタッチメントはECS serviceのload_balancerで設定

######## リスナー ########
resource "aws_lb_listener" "listener" {
  load_balancer_arn  = aws_lb.alb.arn
  port               = "80"
  protocol           = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target.arn
  }
}


