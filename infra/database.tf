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
      - sudo apt update -y >> /var/log/user-data.log 2>&1
      - sudo apt install -y postgresql postgresql-contrib >> /var/log/user-data.log 2>&1
      - echo "PostgreSQL installed." >> /var/log/user-data.log
      - sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/$(pg_ls_clusters --no-header | awk '{print $1}')/main/postgresql.conf >> /var/log/user-data.log
      - echo "Listen address configured." >> /var/log/user-data.log
      - echo "host    all             inapp             0.0.0.0/0                 md5" | sudo tee -a /etc/postgresql/$(pg_ls_clusters --no-header | awk '{print $1}')/main/pg_hba.conf >> /var/log/user-data.log
      - echo "pg_hba.conf configured for backend access." >> /var/log/user-data.log
      - sudo -u postgres psql -c "CREATE USER inapp WITH PASSWORD 'password';" >> /var/log/user-data.log 2>&1
      - echo "Database 'e_commerce_db' and user 'inapp' created." >> /var/log/user-data.log
      - sudo -u postgres psql -c "CREATE DATABASE e_commerce_db OWNER inapp;" >> /var/log/user-data.log 2>&1
      - sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE e_commerce_db TO inapp;" >> /var/log/user-data.log 2>&1
      - echo "All privileges granted to user 'inapp' on database 'e_commerce_db'." >> /var/log/user-data.log
      - sudo systemctl restart postgresql >> /var/log/user-data.log 2>&1
      - echo "PostgreSQL setup completed!" >> /var/log/user-data.log
    EOF
}