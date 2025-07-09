/*
 Copyright (c) 2023, Deductive AI, Inc. All rights reserved.

 This software is the confidential and proprietary information of
 Deductive AI, Inc. You shall not disclose such confidential
 information and shall use it only in accordance with the terms of
 the license agreement you entered into with Deductive AI, Inc.
*/

# Get current AWS account information
data "aws_caller_identity" "current" {}

module "bootstrap" {
  source = "./modules/bootstrap"
  tenant = var.tenant
  customer_subdomain = var.customer_subdomain
  role_info = {
    resource_prefix          = "DeductiveAI"
    external_id              = var.external_id
    deductive_aws_account_id = var.deductive_aws_account_id
  }
  # Additional tags that will be applied to all resources
  additional_tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = "deductive-ai-bootstrap"
    Tenant      = var.tenant
    CustomerSubdomain = var.customer_subdomain != null ? var.customer_subdomain : var.tenant
  }
}
