resource "openstack_compute_instance_v2" "api_server" {
    name            = "E-Commerce-Backend-${count.index}"
    flavor_name   = "t1.small" 
    image_name    = "Debian-Bullseye-Latest"
    count           = 3
    security_groups = [openstack_networking_secgroup_v2.ServerEC_Backend.name] 
    key_pair        = openstack_compute_keypair_v2.keypair1.name 

user_data = <<-EOF
#!/bin/bash
exec > /var/log/user-data.log 2>&1   # Redirect output to log file
set -x  # Enable debugging

echo "Starting backend server setup..."

cd /home/debian
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
export HOME=/home/debian
git config --global --add safe.directory /home/debian/E_Commerce_App

sudo chown -R debian:debian /home/debian/E_Commerce_App

echo "sudo chown terminated"

EOF

}

# Adicione aqui as regras de security group para o backend (semelhante ao frontend)
# Exemplo: Permitir tráfego na porta da API, acesso SSH, etc.
# resource "openstack_networking_secgroup_rule_v2" "backend_api" { ... }
# resource "openstack_networking_secgroup_rule_v2" "backend_ssh" { ... }