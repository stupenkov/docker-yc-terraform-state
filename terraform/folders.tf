resource "yandex_resourcemanager_folder" "env" {
  for_each    = toset(var.environments)
  cloud_id    = yandex_resourcemanager_cloud.app_cloud.id
  name        = each.value
  description = "Folder for ${each.value} environment"
}

resource "yandex_iam_service_account" "env" {
  for_each    = toset(var.environments)
  folder_id   = yandex_resourcemanager_folder.env[each.key].id
  name        = "sa-${each.value}"
  description = "Service account for ${each.value} environment"
}

resource "yandex_resourcemanager_folder_iam_member" "env_editor" {
  for_each  = toset(var.environments)
  folder_id = yandex_resourcemanager_folder.env[each.key].id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.env[each.key].id}"
}

resource "yandex_iam_service_account_static_access_key" "env_static_key" {
  for_each           = toset(var.environments)
  service_account_id = yandex_iam_service_account.env[each.key].id
  description        = "Static access key for ${each.value} service account"
}

output "folder_ids" {
  description = "ID каталогов для каждого окружения"
  value       = { for k, v in yandex_resourcemanager_folder.env : k => v.id }
}

output "service_account_ids" {
  description = "ID сервисных аккаунтов для каждого окружения"
  value       = { for k, v in yandex_iam_service_account.env : k => v.id }
}

output "static_access_keys" {
  description = "Статические ключи доступа для каждого окружения"
  value       = { for k, v in yandex_iam_service_account_static_access_key.env_static_key : k => v }
  sensitive   = true
}

resource "yandex_storage_object" "env_sa_key" {
  for_each = toset(var.environments)
  bucket   = yandex_storage_bucket.infra.bucket
  key      = "sa-${each.value}-key.json"
  content = jsonencode({
    access_key = yandex_iam_service_account_static_access_key.env_static_key[each.key].access_key
    secret_key = yandex_iam_service_account_static_access_key.env_static_key[each.key].secret_key
  })
  depends_on = [
    yandex_storage_bucket.infra,
    yandex_iam_service_account_static_access_key.env_static_key
  ]
}
