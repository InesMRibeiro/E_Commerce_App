resource "aws_security_group" "ServerEC_Backend" {
  name        = "ServerEC_Backend"
  description = "Permitir HTTP, SSH, ICMP" 

    #SSH
    ingress {
        from_port   = 22
        to_port     = 22
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

    #Flask API
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