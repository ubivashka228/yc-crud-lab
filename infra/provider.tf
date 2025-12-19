provider "yandex" {
  service_account_key_file = "${path.module}/keys/sa-terraform-key.json"
  cloud_id                 = "b1grs7o1gvlljvit28u0"
  folder_id                = "b1geuovde4o76tuboe20"
  zone                     = "ru-central1-a"
}
