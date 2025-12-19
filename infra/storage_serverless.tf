# Object Storage bucket (уже создан)
resource "yandex_storage_bucket" "files" {
  bucket = "crud-files-20251218"

  lifecycle {
    prevent_destroy = true
  }
}

# Service account (уже создан)
resource "yandex_iam_service_account" "sa_os_trigger" {
  folder_id = "b1geuovde4o76tuboe20"
  name      = "sa-os-trigger"
}

# Даем SA право вызывать функции (если уже есть — импортнем)
resource "yandex_resourcemanager_folder_iam_member" "sa_os_trigger_invoker" {
  folder_id = "b1geuovde4o76tuboe20"
  role      = "functions.functionInvoker"
  member    = "serviceAccount:${yandex_iam_service_account.sa_os_trigger.id}"
}

# Function (уже создана). Кодом из Terraform не управляем — только "учет" ресурса.
resource "yandex_function" "os_event_logger" {
  name       = "os-event-logger"
  runtime    = "python312"
  entrypoint = "handler.handler"
  memory     = 128

  # заглушка (после import не трогаем content)
  user_hash = "imported"
  content {
    zip_filename = "${path.module}/dummy.zip"
  }

  lifecycle {
    ignore_changes  = [content, user_hash]
    prevent_destroy = true
  }
}

# Trigger (уже создан)
resource "yandex_function_trigger" "os_upload_trigger" {
  name = "os-upload-trigger"

  function {
    id                 = yandex_function.os_event_logger.id
    tag                = "$latest"
    service_account_id = yandex_iam_service_account.sa_os_trigger.id
  }

  object_storage {
    bucket_id    = yandex_storage_bucket.files.bucket
    prefix       = "uploads/"
    create       = true
    batch_size   = 1
    batch_cutoff = 1
  }

  lifecycle {
    prevent_destroy = true
  }
}
