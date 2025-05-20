resource "openstack_networking_secgroup_v2" "manual_lb_sg" {
  name        = "manual-lb-sg"
  description = "Permitir HTTP (5000) e SSH para o load balancer"
}

resource "openstack_networking_secgroup_rule_v2" "manual_lb_http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 80
  port_range_max    = 80
  protocol          = "tcp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.manual_lb_sg.id
}

resource "openstack_networking_secgroup_rule_v2" "manual_lb_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 22
  port_range_max    = 22
  protocol          = "tcp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.manual_lb_sg.id
}
