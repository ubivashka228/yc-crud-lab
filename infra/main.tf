resource "yandex_vpc_network" "net" {
  name = "crud-net"
}

resource "yandex_vpc_subnet" "subnet_a" {
  name           = "crud-subnet-a"
  zone           = var.zone
  network_id     = yandex_vpc_network.net.id
  v4_cidr_blocks = [var.subnet_cidr]
}

# SG для API-инстансов
resource "yandex_vpc_security_group" "sg_api" {
  name       = "crud-sg-api"
  network_id = yandex_vpc_network.net.id

  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = [var.ssh_cidr]
    port           = 22
    description    = "SSH"
  }

  # Трафик на API (для NLB / клиентов). Для лабы можно 0.0.0.0/0.
  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = var.api_port
    description    = "API via NLB (target port)"
  }

  # Healthchecks от балансировщика (оставляем)
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
  name       = "crud-sg-db"
  network_id = yandex_vpc_network.net.id

  # SSH на DB (для лабы/дебага)
  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = [var.ssh_cidr]
    port           = 22
    description    = "SSH"
  }

  # Postgres только от API SG
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
