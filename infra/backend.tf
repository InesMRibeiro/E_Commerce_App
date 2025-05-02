# resource "aws_instance" "api_server" {
#     ami                     = var.ami_id
#     count                   = var.instance_count 
#     instance_type           = var.instance_type
#     security_groups         = [aws_security_group.ServerEC_Backend.name] 
#     key_name                = var.key_name

#     tags = {
#         Name = "E-Commerce - Backend"
#     }

#     user_data = <<-EOF
#                 #!/bin/bash
#                 exec > /var/log/user-data.log 2>&1  # Redirect output to log file
#                 set -x  # Enable debugging

#                 echo "Starting backend server setup..."

#                 cd /home/ubuntu
#                 if [ ! -d "E_Commerce_App" ]; then
#                     git clone https://github.com/InesMRibeiro/E_Commerce_App.git
#                 else
#                     echo "Repository already cloned."
#                 fi

#                 sudo apt update -y
#                 sudo apt install -y python3 python3-pip python3-venv git

#                 python3 -m venv venv
#                 source venv/bin/activate

#                 cd E_Commerce_App/backend

#                 if [ -f "requirements.txt" ]; then
#                      pip install -r requirements.txt
#                 else
#                      echo "requirements.txt not found!" >> /var/log/user-data.log
#                 fi
#                 echo "Backend server setup completed!"

#                 # Mark the directory as safe for Git operations
#                 export HOME=/home/ubuntu
#                 git config --global --add safe.directory /home/ubuntu/E_Commerce_App

#                 sudo chown -R ubuntu:ubuntu /home/ubuntu/E_Commerce_App

#                 echo "sudo chown terminated"
                
#                 EOF
# }