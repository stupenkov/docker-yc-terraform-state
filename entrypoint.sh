#!/bin/bash
set -e

echo "=== Setting up Terraform environment variables ==="

# Request YC Token
read -p "Enter your Yandex Cloud OAuth token (yc_token): " yc_token_input
export YC_TOKEN="$yc_token_input"

# Request variables from variables.tf
read -p "Enter organization_id: " organization_id
export TF_VAR_organization_id="$organization_id"

read -p "Enter billing_account_id: " billing_account_id
export TF_VAR_billing_account_id="$billing_account_id"

read -p "Enter cloud_name: " cloud_name
export TF_VAR_cloud_name="$cloud_name"

# Request Zone
read -p "Enter availability zone (default ru-central1-a): " zone
export YC_ZONE="${zone:-ru-central1-a}"

echo "=== Initializing Terraform ==="
terraform init

echo "=== Running plan ==="
terraform plan

echo "=== Running apply (actions will be confirmed) ==="
terraform apply "$@"

echo "=== Operation completed ==="