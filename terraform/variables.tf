variable "organization_id" {
  description = "Yandex Cloud Organization  ID"
  type        = string
  default     = "bpflh1nomhlsgkpkqdgk"
  validation {
    condition     = length(var.organization_id) > 0
    error_message = "organization_id must not be empty"
  }
}

variable "billing_account_id" {
  description = "Yandex Cloud Billing Account ID"
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.billing_account_id) > 0
    error_message = "billing_account_id must not be empty"
  }
}

variable "cloud_name" {
  description = "Yandex Cloud name for your infrastructure"
  type        = string
  default     = "infrastructure" # You can change this to your cloud name
  validation {
    condition     = length(var.cloud_name) > 0 && can(regex("^[a-z][-a-z0-9]{0,61}[a-z0-9]$", var.cloud_name))
    error_message = "cloud_name must not be empty and must match pattern: ^[a-z][-a-z0-9]{0,61}[a-z0-9]$"
  }
}
