resource "aws_lb" "application_load_balancer" {
  name               = "application-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balancer.id]
  subnets            = ["subnet-0193b63170eafac6e", "subnet-0fca769ee96740c3a", "subnet-0651cc1b98ea6fc52"] # Use todas as 3 subnets
  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

resource "aws_lb_target_group" "target_group" {
  name     = "target-group"
  port     = 5000
  protocol = "HTTP"
  vpc_id   = "vpc-08d919b0d30eb4dd9" # Substitua var.vpc_id pelo seu ID da VPC

  health_check {
    path                = "/" # Adicione um endpoint de health check ao seu backend
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}