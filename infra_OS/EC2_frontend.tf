# Create instance
resource "openstack_compute_instance_v2" "EC2_Frontend" {
  name          = "EC_Frontend"
  flavor_name   = "t1.small"
  image_name    = "Debian-Bullseye-Latest"
  key_pair      = openstack_compute_keypair_v2.keypair1.name
  security_groups = [openstack_networking_secgroup_v2.EC_frontend.name]


  user_data     = <<-EOF
#!/bin/bash
exec > /var/log/user-data.log 2>&1
set -x  # Enables debugging

sudo apt update -y
sudo apt install apt-utils -y
sudo apt install apache2 -y
sudo systemctl enable apache2
sudo systemctl start apache2

cd /var/www/html
echo "<h1>Deploying Frontend</h1>" > index.html

if [ ! -d "E_Commerce_App" ]; then
  cd /home/debian
  git clone https://github.com/InesMRibeiro/E_Commerce_App.git
fi
sudo cp -r /home/debian/E_Commerce_App/frontend/* /var/www/html/

# Mark the directory as safe for Git operations
export HOME=/home/debian
git config --global --add safe.directory /home/debian/E_Commerce_App

sudo chown -R debian:debian /home/debian/E_Commerce_App
EOF
}