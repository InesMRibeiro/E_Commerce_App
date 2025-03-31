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

  user_data = <<-EOF
                sudo apt update -y
                sudo apt install apache2 -y
                sudo systemctl enable apache2
                sudo systemctl start apache2

                cd /var/www/html
                echo "<h1>Deploying Frontend</h1>" > index.html

                cd /home/ubuntu
                if [ ! -d "E_Commerce_App" ]; then
                git clone https://github.com/InesMRibeiro/E_Commerce_App.git
                fi
                sudo cp E_Commerce_App/FrontEnd/* /var/www/html/
                EOF
            
}