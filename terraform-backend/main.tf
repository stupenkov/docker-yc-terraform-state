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

# Outputs
output "bucket" {
  value = yandex_storage_bucket.infra.bucket
}

output "cicd_static_access_key" {
  value     = yandex_iam_service_account_static_access_key.sa-cicd-static-key
  sensitive = true
}
