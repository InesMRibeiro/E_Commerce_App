resource "aws_instance" "database" {
    ami                     = var.ami_id
    instance_type           = var.instance_type
    security_groups         = [aws_security_group.EC_Database.name] 
    key_name                = var.key_name

    tags = {
        Name = "E-Commerce - Database"
    }

    user_data = <<-EOF
                #!/bin/bash
                exec > /var/log/user-data.log 2>&1
                set -x  # Enable debugging

                echo "Starting PostgreSQL setup..."

                sudo apt update -y
                sudo apt install -y postgresql postgresql-contrib

                echo "PostgreSQL installed."

                # Configure PostgreSQL to listen on all interfaces (for testing within VPC)
                sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/$(pg_ls_clusters --no-header | awk '{print $1}')/main/postgresql.conf

                echo "Listen address configured."

                # Configure pg_hba.conf to allow connections from your backend instances

                sudo tee -a /etc/postgresql/$(pg_ls_clusters --no-header | awk '{print $1}')/main/pg_hba.conf <<EOL
host    all             inapp             0.0.0.0/0                 md5
EOL

                echo "pg_hba.conf configured for backend access."

                # Switch to the postgres user to create the database and user
                sudo -u postgres psql -c "CREATE USER inapp WITH PASSWORD 'password';"
                sudo -u postgres psql -c "CREATE DATABASE e_commerce_db OWNER inapp;"

                echo "Database 'e_commerce_db' and user 'inapp' created."

                sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE e_commerce_db TO inapp;"

                echo "All privileges granted to user 'inapp' on database 'e_commerce_db'."

                # Restart PostgreSQL service to apply changes
                sudo systemctl restart postgresql

                echo "PostgreSQL setup completed!"
                EOF
}