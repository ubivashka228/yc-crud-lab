output "network_id" {
  value = yandex_vpc_network.net.id
}

output "subnet_id" {
  value = yandex_vpc_subnet.subnet_a.id
}

output "sg_api_id" {
  value = yandex_vpc_security_group.sg_api.id
}

output "sg_db_id" {
  value = yandex_vpc_security_group.sg_db.id
}

output "db_public_ip" {
  value = yandex_compute_instance.db.network_interface[0].nat_ip_address
}

output "api1_public_ip" {
  value = yandex_compute_instance.api1.network_interface[0].nat_ip_address
}

output "api2_public_ip" {
  value = yandex_compute_instance.api2.network_interface[0].nat_ip_address
}

output "nlb_public_ip" {
  value = tolist(tolist(yandex_lb_network_load_balancer.api_nlb.listener)[0].external_address_spec)[0].address
}