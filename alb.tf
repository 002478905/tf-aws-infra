resource "aws_lb" "web_alb" {
  name               = "web-app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id, aws_subnet.public_subnet_3.id]

  enable_deletion_protection = false

  tags = {
    Name = "web-app-alb"
  }
}

resource "aws_lb_target_group" "web_tg" {
  name     = "web-app-tg"
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.csye6225_vpc.id

  health_check {
    enabled             = true
    interval            = 30
    path                = "/healthz"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn = var.dev_cert

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}