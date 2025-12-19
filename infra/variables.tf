variable "zone" {
  type    = string
  default = "ru-central1-a"
}

variable "network_cidr" {
  type    = string
  default = "10.10.0.0/16"
}

variable "subnet_cidr" {
  type    = string
  default = "10.10.10.0/24"
}

variable "api_port" {
  type    = number
  default = 8000
}

# Для лабы оставим SSH открытым, позже можно сузить до своего IP
variable "ssh_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

variable "ssh_user" {
  type    = string
  default = "ubuntu"
}

variable "ssh_public_key_path" {
  type    = string
  default = "keys/yc_lab.pub"
}

variable "repo_url" {
  type    = string
  default = "https://github.com/ubivashka228/yc-crud-lab.git"
}

variable "secret_key" {
  type    = string
  default = "dev-secret"
}

variable "bootstrap_admin_token" {
  type    = string
  default = "bootstrap-admin-12345"
}

variable "s3_bucket" {
  type = string
}

variable "s3_access_key_id" {
  type      = string
  sensitive = true
}

variable "s3_secret_access_key" {
  type      = string
  sensitive = true
}
