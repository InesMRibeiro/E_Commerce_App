/*Define o grupo de instâncias que serão gerenciadas dinamicamente. 
Referencia o Launch Template (ou Launch Configuration) para saber como criar novas instâncias. 
O ASG também define o tamanho desejado, mínimo e máximo do grupo, as políticas de escalonamento, 
as verificações de saúde e a associação com o Load Balancer.*/


resource "aws_autoscaling_group" "auto_scaling_group" {
    name                 = "auto-scaling-group"
    launch_template {
    id      = aws_launch_template.launch_template.id
    version = "$Latest"
    }
    
    target_group_arns    = [aws_lb_target_group.EC_Backend_TG.arn]
    vpc_zone_identifier = data.aws_subnets.default.ids
    desired_capacity     = 2
    min_size             = 2
    max_size             = 4

    health_check_type    = "ELB"
    health_check_grace_period = 300

    lifecycle {
    create_before_destroy = true
    }
    }

    resource "aws_autoscaling_policy" "cpu_scaling_policy" {
    name                   = "cpu-scaling-policy"
    autoscaling_group_name = aws_autoscaling_group.auto_scaling_group.name
    policy_type            = "TargetTrackingScaling"

    target_tracking_configuration {
    target_value = 50.0
    predefined_metric_specification {
        predefined_metric_type = "ASGAverageCPUUtilization"
    }
    }
}