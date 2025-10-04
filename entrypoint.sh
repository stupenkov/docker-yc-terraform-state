#!/bin/bash
set -e

echo "=== Настройка переменных окружения для Terraform ==="

# Запрос YC Token
read -p "Введите ваш OAuth токен Yandex Cloud (yc_token): " yc_token_input
export YC_TOKEN="$yc_token_input"

# Запрос переменных из variables.tf
read -p "Введите organization_id: " organization_id
export TF_VAR_organization_id="$organization_id"

read -p "Введите billing_account_id: " billing_account_id
export TF_VAR_billing_account_id="$billing_account_id"

read -p "Введите cloud_name: " cloud_name
export TF_VAR_cloud_name="$cloud_name"

# Запрос Zone
read -p "Введите зону доступности (по умолчанию ru-central1-a): " zone
export YC_ZONE="${zone:-ru-central1-a}"

echo "=== Инициализация Terraform ==="
terraform init

echo "=== Выполнение планирования ==="
terraform plan

echo "=== Запуск apply (подтвердите действия) ==="
terraform apply -auto-approve

echo "=== Работа завершена ==="