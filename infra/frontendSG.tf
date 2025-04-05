resource "aws_security_group" "EC_frontend" {
  name        = "EC_frontend"
  description = "Permitir HTTP e SSH"


    #SSH
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"] 
    }

    #HTTP
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"] 
    }

    #ICMP
    ingress {
        from_port   = -1
        to_port     = -1
        protocol    = "icmp"  # Permite ping (ICMP)
        cidr_blocks = ["0.0.0.0/0"]  
    }

    #FLASK
    ingress {
        from_port   = 5000
        to_port     = 5000
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"] 
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"] 
    }

}