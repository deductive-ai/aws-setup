provider "aws" {
  region  = var.region
  profile = var.aws_profile
}

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

module "bootstrap" {
  source = "./modules/bootstrap"

  role_info = {
    resource_prefix          = "DeductiveAI"
    external_id              = var.external_id
    deductive_aws_account_id = var.deductive_aws_account_id
  }

  tenant = var.tenant

  # Additional tags that will be applied to all resources
  additional_tags = {}
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

output "share_with_deductive" {
  description = "The ARNs of the resources to share with Deductive AI"
  value = {
    "deductive_role_arn"   = module.bootstrap.deductive_role_arn
    "eks_cluster_role_arn" = module.bootstrap.eks_cluster_role_arn
    "ec2_role_arn"         = module.bootstrap.ec2_role_arn
  }
} 
