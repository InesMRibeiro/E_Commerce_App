resource "openstack_networking_secgroup_v2" "ServerEC_Backend" {
  name        = "ServerEC_Backend"
  description = "Permitir HTTP (5000), SSH, ICMP e acesso ao banco de dados (5432)"
}

# Regra para SSH
resource "openstack_networking_secgroup_rule_v2" "backend_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 22
  port_range_max    = 22
  protocol          = "tcp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.ServerEC_Backend.id
}

# Regra para ICMP
resource "openstack_networking_secgroup_rule_v2" "backend_icmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.ServerEC_Backend.id
}

# Regra para HTTP (porta 5000)
resource "openstack_networking_secgroup_rule_v2" "backend_http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 5000
  port_range_max    = 5000
  protocol          = "tcp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.ServerEC_Backend.id
}

# Regra para acesso ao banco de dados (porta 5432)
resource "openstack_networking_secgroup_rule_v2" "backend_db_ingress" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 5432
  port_range_max    = 5432
  protocol          = "tcp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.ServerEC_Backend.id
}
