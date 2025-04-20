output "backend-ip" {

     value = [for inst in aws_instance.api_server : inst.public_ip]
}

output "frontend-ip" {

    value = aws_instance.frontend.public_ip
  
}

output "database-ip" {
    
    value = aws_instance.database.public_ip
}

output "load_balancer_dns_name" {
  value = aws_lb.EC_LB.dns_name
  description = "O nome DNS do Application Load Balancer"
}