resource "aws_instance" "database" {
  ami           = var.ami_id
  instance_type = var.instance_type
  security_groups = [aws_security_group.EC_Database.name]
  key_name      = var.key_name

  tags = {
    Name = "E-Commerce - Database"
  }

  user_data = <<-EOF
    #!/bin/bash
    exec > /var/log/user-data.log 2>&1
    set -x

    echo "Iniciando configuração automática do PostgreSQL..."

    # Atualizar pacotes
    sudo apt update -y
    echo "Pacotes atualizados."

    # Instalar PostgreSQL
    sudo apt install -y postgresql postgresql-contrib
    echo "PostgreSQL instalado."

    # Criar utilizador e base de dados PostgreSQL
    sudo -u postgres psql -c "CREATE USER inapp WITH PASSWORD 'inapp';"
    echo "Utilizador 'inapp' criado."

    sudo -u postgres psql -c "CREATE DATABASE inapp_db;"
    echo "Base de dados 'inapp_db' criada."

    sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE inapp_db TO inapp;"
    echo "Privilégios concedidos ao utilizador 'inapp' na base de dados 'inapp_db'."

    # Conceder permissão CREATE no schema public
    sudo -u postgres psql -d inapp_db -c "GRANT CREATE ON SCHEMA public TO inapp;"
    echo "Permissão CREATE concedida ao utilizador 'inapp' no schema public."

    # Alterar listen_addresses no postgresql.conf
    sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/16/main/postgresql.conf
    echo "listen_addresses configurado para '*'."

    # Adicionar regras ao pg_hba.conf
    echo "" >> /etc/postgresql/16/main/pg_hba.conf
    echo "# Configurações adicionadas por user-data" >> /etc/postgresql/16/main/pg_hba.conf
    echo "local   inapp_db         inapp                               md5" >> /etc/postgresql/16/main/pg_hba.conf
    echo "host    inapp_db         inapp          0.0.0.0/0                    md5" >> /etc/postgresql/16/main/pg_hba.conf
    echo "Regras adicionadas ao pg_hba.conf."

    # Reiniciar o PostgreSQL
    sudo systemctl restart postgresql
    echo "PostgreSQL reiniciado."

    echo "Configuração automática do PostgreSQL concluída!"
  EOF
}
