resource "yandex_lb_target_group" "api_tg" {
  name      = "api-tg"
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
  name = "api-nlb"
  type = "external"

  listener {
    name        = "http"
    port        = 80
    target_port = 8000

    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.api_tg.id

    healthcheck {
      name = "http"

      http_options {
        port = 8000
        path = "/health"
      }
    }
  }
}
