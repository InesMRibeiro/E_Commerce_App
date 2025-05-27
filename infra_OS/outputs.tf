output "backend_ips" {
  description = "IP privados dos servidores backend"
  value = [for instance in openstack_compute_instance_v2.api_server : instance.network[0].fixed_ip_v4]
}

output "frontend_ip" {
  description = "IP privado do frontend"
  value = openstack_compute_instance_v2.EC2_Frontend.network[0].fixed_ip_v4
}

output "database_ip" {
  description = "IP privado da database"
  value = openstack_compute_instance_v2.database.network[0].fixed_ip_v4
}

output "loadbalancer_ip" {
  description = "IP privado do Load Balancer"
  value = openstack_compute_instance_v2.manual_lb.network[0].fixed_ip_v4
}
