resource "aws_lb_target_group_attachment" "EC_Backend_Attachments" {
  count            = var.instance_count
  target_group_arn = aws_lb_target_group.EC_Backend_TG.arn
  target_id        = aws_instance.api_server[count.index].id  
  port             = 5000

   depends_on = [aws_lb_target_group.EC_Backend_TG]
}
