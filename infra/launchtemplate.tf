/*Define a configuração das instâncias EC2 que o Auto Scaling Group irá criar. 
Isso inclui a AMI, o tipo de instância, o par de chaves, os security groups, o user_data e
 outras configurações de inicialização da instância. Este é um recurso separado no Terraform porque 
  posso querer reutilizar a mesma configuração de lançamento em diferentes Auto Scaling Groups ou até
mesmo para lançar instâncias EC2 manualmente.*/

resource "aws_launch_template" "launch_template" {
    name_prefix     = "launch-template"
    image_id        = var.ami_id
    instance_type   = var.instance_type
    vpc_security_group_ids = [aws_security_group.ServerEC_Backend.id]
    key_name        = var.key_name

    user_data = base64encode(<<-EOF
                #!/bin/bash
                exec > /var/log/user-data.log 2>&1  # Redirect output to log file
                set -x  # Enable debugging

                echo "Starting backend server setup..."

                cd /home/ubuntu
                if [ ! -d "E_Commerce_App" ]; then
                    git clone https://github.com/InesMRibeiro/E_Commerce_App.git
                else
                    echo "Repository already cloned."
                fi

                sudo apt update -y
                sudo apt install -y python3 python3-pip python3-venv git

                python3 -m venv venv
                source venv/bin/activate

                cd E_Commerce_App/backend

                if [ -f "requirements.txt" ]; then
                        pip install -r requirements.txt
                else
                        echo "requirements.txt not found!" >> /var/log/user-data.log
                fi
                echo "Backend server setup completed!"

                # Mark the directory as safe for Git operations
                export HOME=/home/ubuntu
                git config --global --add safe.directory /home/ubuntu/E_Commerce_App

                sudo chown -R ubuntu:ubuntu /home/ubuntu/E_Commerce_App

                EOF
    )
}