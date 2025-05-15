resource "openstack_networking_secgroup_v2" "EC_frontend" {
  name        = "EC_frontend"
  description = "Permitir HTTP, SSH, ICMP e Flask"
}

# Regra para SSH
resource "openstack_networking_secgroup_rule_v2" "ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 22
  port_range_max    = 22
  protocol          = "tcp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.EC_frontend.id
}

# Regra para HTTP
resource "openstack_networking_secgroup_rule_v2" "http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 80
  port_range_max    = 80
  protocol          = "tcp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.EC_frontend.id
}

# Regra para ICMP (para ping)
resource "openstack_networking_secgroup_rule_v2" "icmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.EC_frontend.id
}

# Regra para Flask
resource "openstack_networking_secgroup_rule_v2" "flask" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 5000
  port_range_max    = 5000
  protocol          = "tcp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.EC_frontend.id
}

