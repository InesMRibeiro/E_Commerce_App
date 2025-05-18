resource "openstack_networking_secgroup_v2" "EC_Database" {
  name        = "EC_Database"
  description = "Permitir SSH, ICMP e acesso PostgreSQL"
}

# Regra para SSH
resource "openstack_networking_secgroup_rule_v2" "db_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 22
  port_range_max    = 22
  protocol          = "tcp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.EC_Database.id
}

# Regra para ICMP
resource "openstack_networking_secgroup_rule_v2" "db_icmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.EC_Database.id
}

# Regra para acesso PostgreSQL (porta 5432)
resource "openstack_networking_secgroup_rule_v2" "db_postgres" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 5432
  port_range_max    = 5432
  protocol          = "tcp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.EC_Database.id
}
