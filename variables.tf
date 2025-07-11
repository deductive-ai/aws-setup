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
  description = "Tenant identifier for multi-tenant deployments (optional)"
  type        = string
  default     = null
  nullable    = true
}

variable "use_local_backend" {
  description = "If true, use local backend instead of S3. Useful for development/testing."
  type        = bool
  default     = false
} 