resource "aws_instance" "frontend" {
  ami                     = var.ami_id
  instance_type           = var.instance_type
  subnet_id               = aws_subnet.app_subnet.id
  vpc_security_group_ids  = [aws_security_group.frontendSG.id]
  key_name = var.key_name
  associate_public_ip_address = true

  tags = {
    Name = "FrontEnd-Instance"
  }
}