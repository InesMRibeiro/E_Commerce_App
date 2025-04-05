resource "aws_instance" "frontend" {
  ami                     = var.ami_id
  instance_type           = var.instance_type
  security_groups         = [aws_security_group.EC_frontend.name] 
  key_name                = var.key_name

  tags = {
    Name = "E-Commerce - Frontend"
  }

  user_data = <<-EOF
                #!/bin/bash
                exec > /var/log/user-data.log 2>&1
                set -x  # Enables debugging


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
                sudo cp  -r E_Commerce_App/frontend/* /var/www/html/
                EOF
            
}