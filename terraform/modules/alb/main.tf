resource "aws_lb" "alb" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = var.lb_type
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnets

  enable_deletion_protection = false

  tags = {
    Name = var.alb_name
  }
}

resource "aws_lb_target_group" "ip_target_group" {
  name             = var.tg_name
  port             = var.target_group_port
  protocol         = "HTTP"
  protocol_version = "HTTP1"
  target_type      = var.target_type
  vpc_id           = var.vpc_id
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = var.listener_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ip_target_group.arn
  }
}