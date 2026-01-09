# Object Storage bucket (создаём новый)
resource "yandex_storage_bucket" "attachments" {
  bucket    = var.s3_bucket
  folder_id = var.folder_id
}

# Service account для триггера (который будет вызывать функцию)
resource "yandex_iam_service_account" "sa_evt_trigger" {
  folder_id = var.folder_id
  name      = "sa-attachments-trigger"
}

# Даём SA право вызывать функции
resource "yandex_resourcemanager_folder_iam_member" "sa_evt_trigger_invoker" {
  folder_id = var.folder_id
  role      = "functions.functionInvoker"
  member    = "serviceAccount:${yandex_iam_service_account.sa_evt_trigger.id}"
}

# Cloud Function: логирует события Object Storage (создаём новую)
resource "yandex_function" "attachments_event_logger" {
  name       = "attachments-event-logger"
  runtime    = "python312"
  entrypoint = "handler.handler"
  memory     = 128

  # чтобы функция обновлялась при смене zip
  user_hash = filebase64sha256("${path.module}/../serverless/os_event_logger.zip")

  content {
    zip_filename = "${path.module}/../serverless/os_event_logger.zip"
  }
}

# Trigger: реагирует на создание объектов с префиксом attachments/
resource "yandex_function_trigger" "attachments_created_trigger" {
  name = "attachments-created-trigger"

  function {
    id                 = yandex_function.attachments_event_logger.id
    tag                = "$latest"
    service_account_id = yandex_iam_service_account.sa_evt_trigger.id
  }

  object_storage {
    bucket_id    = yandex_storage_bucket.attachments.bucket
    prefix       = "attachments/"
    create       = true
    batch_size   = 1
    batch_cutoff = 1
  }

  depends_on = [yandex_resourcemanager_folder_iam_member.sa_evt_trigger_invoker]
}
