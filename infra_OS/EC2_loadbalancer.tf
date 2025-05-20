
data "openstack_networking_network_v2" "lb_network" {
    name = "n-iac-pic"
}


resource "openstack_compute_instance_v2" "manual_lb" {
  name            = "manual-loadbalancer-nginx"
  flavor_name     = "t1.small" # Escolhe um flavor adequado
  image_name      = "Debian-Bullseye-Latest" # A mesma imagem das outras instâncias
  key_pair        = openstack_compute_keypair_v2.keypair1.name
  security_groups = [openstack_networking_secgroup_v2.manual_lb_sg.name]

  user_data = <<-EOF
#!/bin/bash
exec > /var/log/user-data.log 2>&1
set -x

sudo apt update -y
sudo apt install -y nginx

# Configurar o Nginx como load balancer (substituir pelos IPs reais das backends)
cat <<EOF > /etc/nginx/conf.d/loadbalancer.conf
upstream backend {
    least_conn; 

    server ${openstack_compute_instance_v2.api_server[0].network[0].fixed_ip_v4}:5000;
    server ${openstack_compute_instance_v2.api_server[1].network[0].fixed_ip_v4}:5000;
    server ${openstack_compute_instance_v2.api_server[2].network[0].fixed_ip_v4}:5000;
}

server {
    listen 80;

    location / {
        proxy_pass http://backend;
    }
}
sudo rm /etc/nginx/sites-enabled/default
sudo systemctl enable nginx
sudo systemctl restart nginx
EOF
}