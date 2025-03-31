resource "aws_instance" "api_server" {
    ami                     = var.ami_id
    instance_type           = var.instance_type
    subnet_id               = aws_subnet.app_subnet.id 
    vpc_security_group_ids  = [aws_security_group.backendSG.id] 
    key_name                = var.key_name
    associate_public_ip_address = true

    tags = {
        Name = "Backend-Instance"
    }

    user_data = <<-EOF
                 #!/bin/bash
                cd /home/ubuntu
                git clone https://github.com/InesMRibeiro/E_Commerce_App.git
                sudo apt update -y
                sudo apt install -y python3 python3-pip python3-venv git
                python3 -m venv venv
                source venv/bin/activate
                cd E_Commerce_App/backend
                pip install -r requirements.txt
                EOF
}