# IAM / Ролевая модель

## Кто что делает

### 1) sa-terraform
Назначение: сервисный аккаунт для Terraform (создание/изменение ресурсов инфраструктуры).

Права:
- folder role: `editor` (достаточно для создания VPC, VM, LB, bucket, functions, triggers и т.д.)

### 2) sa-os-trigger (id: ajeksumi1oo04ahko1mm)
Назначение: используется триггером Object Storage для вызова Cloud Function.

Права:
- folder role: `functions.functionInvoker`

### 3) S3 access key (используется backend)
Назначение: backend загружает файлы в Object Storage и выдаёт presigned URL.

Где используется:
- переменные окружения `S3_ACCESS_KEY_ID`, `S3_SECRET_ACCESS_KEY`, `S3_BUCKET`, `S3_ENDPOINT_URL`.

Примечание по безопасности (для лабы):
- ключ должен иметь минимальные права на работу с bucket (put/get/list) и храниться в `.env`/секретах деплоя.
