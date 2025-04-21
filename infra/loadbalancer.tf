resource "aws_lb" "EC_LB" {
  name               = "EC-LB"
  internal           = false
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.lb_sg.id]
}
 
resource "aws_lb_target_group" "EC_Backend_TG" {
  name        = "EC-Backend-TG"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "instance"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-499"
  }
}
 

resource "aws_lb_listener" "EC_Listener" {

  load_balancer_arn = aws_lb.EC_LB.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
  type             = "forward"
  target_group_arn = aws_lb_target_group.EC_Backend_TG.arn

  }
}