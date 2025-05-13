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
    resource_prefix         = "Deductive"
    external_id             = var.external_id
    deductive_aws_account_id = var.deductive_aws_account_id
    cluster_name            = var.cluster_name
  }

  # Additional tags that will be applied to all resources
  additional_tags = {}
}

variable "cluster_name" {
  description = "Cluster name for the provisioned eks"
  type        = string
  default     = null
  nullable    = true
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

output "share_with_deductive" {
  description = "The ARNs of the resources to share with Deductive"
  value = {
    "deductive_role_arn"   = module.bootstrap.deductive_role_arn
    "eks_cluster_role_arn" = module.bootstrap.eks_cluster_role_arn
    "ec2_role_arn"         = module.bootstrap.ec2_role_arn
  }
} 