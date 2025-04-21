resource "aws_instance" "database" {
    ami                     = var.ami_id
    instance_type           = var.instance_type
    security_groups         = [aws_security_group.EC_Database.name] 
    key_name                = var.key_name

    tags = {
        Name = "E-Commerce - Database"
    }

    user_data = <<-EOF
    #cloud-config
    runcmd:
      - sudo apt update -y
      - sudo apt install -y postgresql postgresql-contrib
      - echo "PostgreSQL installed." > /var/log/user-data.log
      - sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/$(pg_ls_clusters --no-header | awk '{print $1}')/main/postgresql.conf
      - echo "Listen address configured." >> /var/log/user-data.log
      - sudo tee -a /etc/postgresql/$(pg_ls_clusters --no-header | awk '{print $1}')/main/pg_hba.conf <<EOL
host    all             inapp             0.0.0.0/0                 md5
EOL
      - echo "pg_hba.conf configured for backend access." >> /var/log/user-data.log
      - sudo -u postgres psql -c "CREATE USER inapp WITH PASSWORD 'password';"
      - echo "Database 'e_commerce_db' and user 'inapp' created." >> /var/log/user-data.log
      - sudo -u postgres psql -c "CREATE DATABASE e_commerce_db OWNER inapp;"
      - sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE e_commerce_db TO inapp;"
      - echo "All privileges granted to user 'inapp' on database 'e_commerce_db'." >> /var/log/user-data.log
      - sudo systemctl restart postgresql
      - echo "PostgreSQL setup completed!" >> /var/log/user-data.log
    EOF
}
