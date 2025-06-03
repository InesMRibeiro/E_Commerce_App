resource "openstack_compute_instance_v2" "database" {
  name            = "E-Commerce - Database"
  flavor_name     = "t1.small"
  image_name      = "Debian-Bullseye-Latest"
  security_groups = [openstack_networking_secgroup_v2.EC_Database.name]
  key_pair        = openstack_compute_keypair_v2.keypair1.name

  user_data = <<EOF
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

sudo -u postgres psql -c "CREATE DATABASE inapp_db;"
echo "Base de dados 'inapp_db' criada."

# Definir password para o usuário postgres
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'postgres';"
echo "Password para o usuário postgres definida."

# Alterar listen_addresses no postgresql.conf
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/13/main/postgresql.conf
echo "listen_addresses configurado para '*'."

# Adicionar regras ao pg_hba.conf
echo "" >> /etc/postgresql/13/main/pg_hba.conf
echo "# Configurações adicionadas por user-data" >> /etc/postgresql/13/main/pg_hba.conf
echo "local   all             postgres                                md5" >> /etc/postgresql/13/main/pg_hba.conf # Correção importante
echo "host    inapp_db         postgres              0.0.0.0/0                 md5" >> /etc/postgresql/13/main/pg_hba.conf
echo "Regras adicionadas ao pg_hba.conf."

# Reiniciar o PostgreSQL
sudo systemctl restart postgresql
echo "PostgreSQL reiniciado."

# Conectar à base de dados e criar as tabelas
# Conectar à base de dados, criar tabelas e utilizador admin
sudo -u postgres psql -d inapp_db <<SQL
CREATE TABLE IF NOT EXISTS public."user" (
  id SERIAL PRIMARY KEY,
  username VARCHAR(100) NOT NULL,
  password VARCHAR(128) NOT NULL,
  role VARCHAR(20) DEFAULT 'user'
);

CREATE TABLE IF NOT EXISTS public.products (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  price FLOAT NOT NULL,
  qty INTEGER,
  image_url VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS public.cart (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES public."user"(id),
  product_id INTEGER NOT NULL REFERENCES public.products(id),
  quantity INTEGER DEFAULT 1
);

-- Criar utilizador admin se não existir
INSERT INTO public."user" (username, password, role)
VALUES ('admin', 'admin', 'admin')
ON CONFLICT DO NOTHING;
SQL

echo "Tabelas 'user', 'products' e 'cart' criadas."

# Reiniciar o PostgreSQL
sudo systemctl restart postgresql
echo "PostgreSQL reiniciado."

echo "Configuração automática do PostgreSQL concluída!"
EOF
}
