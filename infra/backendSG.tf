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

    #Flask API to Frontend
    ingress {
        from_port   = 5000
        to_port     = 5000
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]  
    }

    #Flask API to Database
      ingress {
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]  
    }

    #Permitir tráfego de saída para a porta 5432 para comunicação com o banco de dados
    
    #egress {
        #from_port   = 5432
        #to_port     = 5432
        #protocol    = "tcp"
        #cidr_blocks = ["<IP do banco de dados>/32"]  # Permita apenas a instância do banco de dados (substitua <IP do banco de dados>)
    #}

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"] 
    }

}