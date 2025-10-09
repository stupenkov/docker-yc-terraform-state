resource "yandex_resourcemanager_cloud" "app_cloud" {
  name            = var.cloud_name
  description     = "Cloud for ${var.cloud_name} application"
  organization_id = var.organization_id
}

resource "yandex_billing_cloud_binding" "binding" {
  billing_account_id = var.billing_account_id
  cloud_id           = yandex_resourcemanager_cloud.app_cloud.id
}

# Fix long-term billing binding
resource "time_sleep" "wait_for_cloud_activation" {
  depends_on      = [yandex_billing_cloud_binding.binding]
  create_duration = "30s"
}

resource "yandex_resourcemanager_folder" "infra" {
  cloud_id    = yandex_resourcemanager_cloud.app_cloud.id
  name        = "infrastructure"
  description = "Folder for infrastructure components"
}

resource "yandex_storage_bucket" "infra" {
  bucket     = "terraform-state-${yandex_resourcemanager_cloud.app_cloud.name}-${yandex_resourcemanager_cloud.app_cloud.id}"
  folder_id  = yandex_resourcemanager_folder.infra.id
  depends_on = [time_sleep.wait_for_cloud_activation]
}

resource "yandex_storage_bucket" "test" {
  bucket     = "test-state-${yandex_resourcemanager_cloud.app_cloud.name}-${yandex_resourcemanager_cloud.app_cloud.id}"
  folder_id  = yandex_resourcemanager_folder.test.id
  depends_on = [time_sleep.wait_for_cloud_activation]
}

resource "yandex_storage_bucket" "prod" {
  bucket     = "prod-state-${yandex_resourcemanager_cloud.app_cloud.name}-${yandex_resourcemanager_cloud.app_cloud.id}"
  folder_id  = yandex_resourcemanager_folder.prod.id
  depends_on = [time_sleep.wait_for_cloud_activation]
}

# Service accounts
resource "yandex_iam_service_account" "cicd" {
  folder_id   = yandex_resourcemanager_folder.infra.id
  name        = "sa-cicd"
  description = "Service account for CI/CD pipelines "
}

resource "yandex_resourcemanager_folder_iam_member" "cicd_editor" {
  folder_id = yandex_resourcemanager_folder.infra.id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.cicd.id}"
}

resource "yandex_iam_service_account_static_access_key" "sa-cicd-static-key" {
  service_account_id = yandex_iam_service_account.cicd.id
  description        = "Static access key for CI/CD service account"
}

# Folders for test and prod environments
resource "yandex_resourcemanager_folder" "test" {
  cloud_id    = yandex_resourcemanager_cloud.app_cloud.id
  name        = "test"
  description = "Folder for test environment"
}

resource "yandex_resourcemanager_folder" "prod" {
  cloud_id    = yandex_resourcemanager_cloud.app_cloud.id
  name        = "prod"
  description = "Folder for production environment"
}

# Service accounts for test and prod environments
resource "yandex_iam_service_account" "test" {
  folder_id   = yandex_resourcemanager_folder.test.id
  name        = "sa-test"
  description = "Service account for test environment"
}

resource "yandex_iam_service_account" "prod" {
  folder_id   = yandex_resourcemanager_folder.prod.id
  name        = "sa-prod"
  description = "Service account for production environment"
}

# IAM roles for test and prod service accounts
resource "yandex_resourcemanager_folder_iam_member" "test_editor" {
  folder_id = yandex_resourcemanager_folder.test.id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.test.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "prod_editor" {
  folder_id = yandex_resourcemanager_folder.prod.id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.prod.id}"
}

# Static access keys for test and prod service accounts
resource "yandex_iam_service_account_static_access_key" "test-static-key" {
  service_account_id = yandex_iam_service_account.test.id
  description        = "Static access key for test service account"
}

resource "yandex_iam_service_account_static_access_key" "prod-static-key" {
  service_account_id = yandex_iam_service_account.prod.id
  description        = "Static access key for production service account"
}

# Outputs
output "bucket" {
  value = yandex_storage_bucket.infra.bucket
}

output "cicd_static_access_key" {
  value     = yandex_iam_service_account_static_access_key.sa-cicd-static-key
  sensitive = true
}

output "test_folder_id" {
  value = yandex_resourcemanager_folder.test.id
}

output "prod_folder_id" {
  value = yandex_resourcemanager_folder.prod.id
}

output "test_service_account_id" {
  value = yandex_iam_service_account.test.id
}

output "prod_service_account_id" {
  value = yandex_iam_service_account.prod.id
}

output "test_static_access_key" {
  value     = yandex_iam_service_account_static_access_key.test-static-key
  sensitive = true
}

output "prod_static_access_key" {
  value     = yandex_iam_service_account_static_access_key.prod-static-key
  sensitive = true
}
# Сохранение ключей сервисных аккаунтов в бакеты
resource "yandex_storage_object" "test_sa_key" {
  bucket = yandex_storage_bucket.test.bucket
  key    = "sa-test-key.json"
  content = jsonencode({
    access_key = yandex_iam_service_account_static_access_key.test-static-key.access_key
    secret_key = yandex_iam_service_account_static_access_key.test-static-key.secret_key
  })
  depends_on = [
    yandex_storage_bucket.test,
    yandex_iam_service_account_static_access_key.test-static-key
  ]
}

resource "yandex_storage_object" "prod_sa_key" {
  bucket = yandex_storage_bucket.prod.bucket
  key    = "sa-prod-key.json"
  content = jsonencode({
    access_key = yandex_iam_service_account_static_access_key.prod-static-key.access_key
    secret_key = yandex_iam_service_account_static_access_key.prod-static-key.secret_key
  })
  depends_on = [
    yandex_storage_bucket.prod,
    yandex_iam_service_account_static_access_key.prod-static-key
  ]
}
