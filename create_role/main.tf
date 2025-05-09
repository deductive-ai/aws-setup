/*
 Copyright (c) 2023, Deductive AI, Inc. All rights reserved.

 This software is the confidential and proprietary information of
 Deductive AI, Inc. You shall not disclose such confidential
 information and shall use it only in accordance with the terms of
 the license agreement you entered into with Deductive AI, Inc.
*/

# The purpose of this script is to create a role for DeductiveAI in Customer's
# AWS account. This role can then be assumed by DeductiveAI to deploy services
# necessary for its operations in the Customer's AWS account.
# terraform apply -var="region=us-east-2" -var="aws_profile=myprofile"
#
# The script outputs the ARN for the newly created role and that needs to be
# shared back to Deductive.

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

module "bootstrap_roles" {
  source = "./modules/deductive_role"

  resource_prefix        = "Deductive"  # Can be customized if needed
  external_id            = var.external_id
  deductive_aws_account_id = var.deductive_aws_account_id

  # Additional tags that will be applied to all resources
  additional_tags = {}
}

output "share_with_deductive" {
  description = "The ARNs of the resources to share with Deductive"
  value = {
    "deductive_role_arn"   = module.bootstrap_roles.deductive_role_arn
    "eks_cluster_role_arn" = module.bootstrap_roles.eks_cluster_role_arn
    "ec2_role_arn"         = module.bootstrap_roles.ec2_role_arn
  }
}
