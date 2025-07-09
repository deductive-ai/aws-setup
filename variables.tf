variable "region" {
  description = "The AWS region to create resources in"
  type        = string
  default     = "us-west-1"
}

variable "aws_profile" {
  description = "AWS profile to use as credential"
  type        = string
  default     = "default"
}

variable "environment" {
  description = "Environment name (development, staging, production)"
  type        = string
  default     = "production"
  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "Environment must be one of: development, staging, production."
  }
}

# External ID and AWS account ID
variable "external_id" {
  description = "External ID (unique) for organization or company"
  type        = string
  default     = null
  nullable    = true
  sensitive   = true
}

variable "deductive_aws_account_id" {
  description = "Deductive AI's AWS account ID(s)"
  type        = string
  default     = null
  nullable    = true
  sensitive   = true
}

variable "tenant" {
  description = "Tenant identifier for multi-tenant deployments"
  type        = string
  nullable    = false
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-_]*[a-zA-Z0-9]$", var.tenant)) || length(var.tenant) == 1
    error_message = "Tenant must be a valid identifier (alphanumeric, hyphens, and underscores only, not starting/ending with special characters)."
  }
}

variable "customer_subdomain" {
  description = "Customer subdomain for app-ui access (will be [customer_subdomain].deductive.ai)"
  type        = string
  default     = null
  nullable    = true
  validation {
    condition = var.customer_subdomain == null || can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.customer_subdomain))
    error_message = "Customer subdomain must be lowercase alphanumeric with hyphens, not starting/ending with hyphens."
  }
}

variable "use_local_backend" {
  description = "If true, use local backend instead of S3. Useful for development/testing. Note: Backend configuration cannot use variables directly - manually comment/uncomment the backend block in providers.tf"
  type        = bool
  default     = false
} 