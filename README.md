# Docker image for working with Yandex Cloud and Terraform

This Docker image allows you to manage Yandex Cloud infrastructure using Terraform in an isolated environment without the need to install Terraform and YC CLI on your local machine.

## Building the image

```bash
docker build -t yc-terraform-state .
```

## Usage

The image automatically requests the necessary parameters when launched:

```bash
docker run --rm -it yc-terraform-state
```

1. **Yandex Cloud OAuth token** - authentication token for the cloud
2. **organization_id** - Yandex Cloud Organization ID
3. **billing_account_id** - Yandex Cloud Billing Account ID
4. **cloud_name** - name for your cloud infrastructure
5. **Availability zone** - zone where resources will be created (default ru-central1-a)

## Features

- Based on the `stupean/yandex-terraform:latest` image
- Automatic Terraform initialization on startup
- Interactive input of all required variables
- Support for all standard Terraform arguments
- Isolated execution environment without dependency on local tool installation

## Project structure

- `Dockerfile` - image build file
- `entrypoint.sh` - initialization and startup script
- `terraform/` - directory with Terraform configuration
