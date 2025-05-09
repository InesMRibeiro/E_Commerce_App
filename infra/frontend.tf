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

                # Mark the directory as safe for Git operations
                export HOME=/home/ubuntu
                git config --global --add safe.directory /home/ubuntu/E_Commerce_App

                sudo chown -R ubuntu:ubuntu /home/ubuntu/E_Commerce_App

                EOF

 /** provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      host        = aws_instance.api_server[0].public_ip
    }
    inline = [
      "sudo sed -i 's/CORS(app, resources={\"*\": {\"origins\": \"http:\\/\\/[0-9\\.]\\+\"\\}}})/CORS(app, resources={\"*\": {\"origins\": \"http:\\/\\/${self.public_ip}\"}})/' /home/ubuntu/E_Commerce_App/backend/app.py",
      "echo \"Frontend IP updated in backend app.py to: ${self.public_ip}\"",
    ]
  }
*/          
}