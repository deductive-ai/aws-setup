provider "aws" {
  region  = var.region
  profile = var.aws_profile
}

variable "region" {
  description = "The AWS region to create resources in"
  type        = string
  default     = "us-east-2"
}

variable "aws_profile" {
  description = "AWS profile to use as credential"
  type        = string
  default     = "default"
}

module "bootstrap" {
  source = "./modules/bootstrap"

  role_info = {
    resource_prefix          = "Deductive"
    external_id              = var.external_id
    deductive_aws_account_id = var.deductive_aws_account_id
  }

  # Pass tenant for role naming
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

# Backend configuration for S3 remote state
# This will be configured at runtime using partial configuration
terraform {
  backend "s3" {
    bucket              = "deductive-ai-iac"
    key                 = "terraform.tfstate"
    region              = "us-east-2"
    encrypt             = true
    workspace_key_prefix = ""
  }
}

# Tenant variable for multi-tenancy support
# This will be used as the workspace name
variable "tenant" {
  description = "Tenant identifier for multi-tenant deployments (must match workspace name)"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-_]*[a-zA-Z0-9]$", var.tenant)) || length(var.tenant) == 1
    error_message = "Tenant must be a valid identifier (alphanumeric, hyphens, and underscores only, not starting/ending with special characters)."
  }
}

# Validation to ensure tenant matches workspace
locals {
  workspace_tenant_match = terraform.workspace == "default" ? true : terraform.workspace == var.tenant
}

# This will fail if tenant doesn't match workspace
resource "null_resource" "tenant_workspace_validation" {
  count = local.workspace_tenant_match ? 0 : 1
  
  provisioner "local-exec" {
    command = "echo 'ERROR: Tenant variable (${var.tenant}) must match current workspace (${terraform.workspace})' && exit 1"
  }
}

output "share_with_deductive" {
  description = "The ARNs of the resources to share with Deductive"
  value = {
    "deductive_role_arn"   = module.bootstrap.deductive_role_arn
    "eks_cluster_role_arn" = module.bootstrap.eks_cluster_role_arn
    "ec2_role_arn"         = module.bootstrap.ec2_role_arn
  }
} 
