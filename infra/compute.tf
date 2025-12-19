data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}

locals {
  ssh_public_key = trimspace(file("${path.module}/${var.ssh_public_key_path}"))
}

resource "yandex_compute_instance" "db" {
  name = "crud-db"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 15
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet_a.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.sg_db.id]
  }

  metadata = {
    ssh-keys  = "${var.ssh_user}:${local.ssh_public_key}"
    user-data = <<-EOF
      #cloud-config
      package_update: true
      packages:
        - docker.io

      write_files:
        - path: /usr/local/bin/bootstrap_db.sh
          permissions: '0755'
          content: |
            #!/usr/bin/env bash
            set -euo pipefail

            systemctl enable --now docker

            mkdir -p /opt/pgdata

            cat > /opt/pg.env <<'ENV'
            POSTGRES_DB=app
            POSTGRES_USER=app
            POSTGRES_PASSWORD=app
            ENV

            docker rm -f pg || true
            docker run -d --restart always --name pg \
              --env-file /opt/pg.env \
              -p 5432:5432 \
              -v /opt/pgdata:/var/lib/postgresql/data \
              postgres:16-alpine

      runcmd:
        - [ bash, -lc, "/usr/local/bin/bootstrap_db.sh" ]
    EOF
  }
}

resource "yandex_compute_instance" "api1" {
  name = "crud-api-1"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 15
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet_a.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.sg_api.id]
  }

  metadata = {
    ssh-keys  = "${var.ssh_user}:${local.ssh_public_key}"
    user-data = <<-EOF
      #cloud-config
      package_update: true
      packages:
        - docker.io
        - git
        - netcat-openbsd

      write_files:
        - path: /usr/local/bin/bootstrap_api1.sh
          permissions: '0755'
          content: |
            #!/usr/bin/env bash
            set -euo pipefail

            systemctl enable --now docker

            rm -rf /opt/app || true
            git clone ${var.repo_url} /opt/app
            cd /opt/app
            docker build -t yc-api:latest .

            # ждём Postgres
            for i in $(seq 1 60); do
              nc -z -w 1 ${yandex_compute_instance.db.network_interface[0].ip_address} 5432 && break
              sleep 2
            done

            cat > /opt/app/.env.runtime <<'ENV'
            PORT=8000
            API_PREFIX=/api
            DATABASE_URL=postgresql+asyncpg://app:app@${yandex_compute_instance.db.network_interface[0].ip_address}:5432/app
            SECRET_KEY=${var.secret_key}
            BOOTSTRAP_ADMIN_TOKEN=${var.bootstrap_admin_token}
            S3_ENDPOINT_URL=https://storage.yandexcloud.net
            S3_REGION=ru-central1
            S3_BUCKET=${var.s3_bucket}
            S3_ACCESS_KEY_ID=${var.s3_access_key_id}
            S3_SECRET_ACCESS_KEY=${var.s3_secret_access_key}
            ENV

            docker run --rm --env-file /opt/app/.env.runtime yc-api:latest alembic upgrade head

            docker rm -f api || true
            docker run -d --restart always --name api --env-file /opt/app/.env.runtime -p 8000:8000 yc-api:latest

      runcmd:
        - [ bash, -lc, "/usr/local/bin/bootstrap_api1.sh" ]
    EOF
  }

  depends_on = [yandex_compute_instance.db]
}

resource "yandex_compute_instance" "api2" {
  name = "crud-api-2"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 15
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet_a.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.sg_api.id]
  }

  metadata = {
    ssh-keys  = "${var.ssh_user}:${local.ssh_public_key}"
    user-data = <<-EOF
      #cloud-config
      package_update: true
      packages:
        - docker.io
        - git
        - netcat-openbsd

      write_files:
        - path: /usr/local/bin/bootstrap_api2.sh
          permissions: '0755'
          content: |
            #!/usr/bin/env bash
            set -euo pipefail

            systemctl enable --now docker

            rm -rf /opt/app || true
            git clone ${var.repo_url} /opt/app
            cd /opt/app
            docker build -t yc-api:latest .

            for i in $(seq 1 60); do
              nc -z -w 1 ${yandex_compute_instance.db.network_interface[0].ip_address} 5432 && break
              sleep 2
            done

            cat > /opt/app/.env.runtime <<'ENV'
            PORT=8000
            API_PREFIX=/api
            DATABASE_URL=postgresql+asyncpg://app:app@${yandex_compute_instance.db.network_interface[0].ip_address}:5432/app
            SECRET_KEY=${var.secret_key}
            BOOTSTRAP_ADMIN_TOKEN=${var.bootstrap_admin_token}
            S3_ENDPOINT_URL=https://storage.yandexcloud.net
            S3_REGION=ru-central1
            S3_BUCKET=${var.s3_bucket}
            S3_ACCESS_KEY_ID=${var.s3_access_key_id}
            S3_SECRET_ACCESS_KEY=${var.s3_secret_access_key}
            ENV

            docker rm -f api || true
            docker run -d --restart always --name api --env-file /opt/app/.env.runtime -p 8000:8000 yc-api:latest

      runcmd:
        - [ bash, -lc, "/usr/local/bin/bootstrap_api2.sh" ]
    EOF
  }

  depends_on = [yandex_compute_instance.db]
}
