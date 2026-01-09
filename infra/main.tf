resource "yandex_vpc_network" "net" {
  name = "req-net"
}

resource "yandex_vpc_subnet" "subnet_a" {
  name           = "req-subnet-a"
  zone           = var.zone
  network_id     = yandex_vpc_network.net.id
  v4_cidr_blocks = [var.subnet_cidr]
}

# SG для API-инстансов
resource "yandex_vpc_security_group" "sg_api" {
  name       = "req-sg-api"
  network_id = yandex_vpc_network.net.id

  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = [var.ssh_cidr]
    port           = 22
    description    = "SSH"
  }

  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = var.api_port
    description    = "API target port"
  }

  ingress {
    protocol          = "TCP"
    port              = var.api_port
    predefined_target = "loadbalancer_healthchecks"
    description       = "LB healthchecks"
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "Outbound all"
  }
}

# SG для Postgres: доступ только от sg_api
resource "yandex_vpc_security_group" "sg_db" {
  name       = "req-sg-db"
  network_id = yandex_vpc_network.net.id

  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = [var.ssh_cidr]
    port           = 22
    description    = "SSH"
  }

  ingress {
    protocol          = "TCP"
    port              = 5432
    security_group_id = yandex_vpc_security_group.sg_api.id
    description       = "Postgres only from API SG"
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "Outbound all"
  }
}
