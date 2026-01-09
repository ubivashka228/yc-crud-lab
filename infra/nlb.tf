resource "yandex_lb_target_group" "api_tg" {
  name      = "req-tg"
  region_id = "ru-central1"

  target {
    subnet_id = yandex_vpc_subnet.subnet_a.id
    address   = yandex_compute_instance.api1.network_interface[0].ip_address
  }

  target {
    subnet_id = yandex_vpc_subnet.subnet_a.id
    address   = yandex_compute_instance.api2.network_interface[0].ip_address
  }
}

resource "yandex_lb_network_load_balancer" "api_nlb" {
  name = "req-nlb"
  type = "external"

  listener {
    name        = "http"
    port        = 80
    target_port = var.api_port

    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.api_tg.id

    healthcheck {
      name = "http"

      http_options {
        port = var.api_port
        path = "/health"
      }
    }
  }
}
