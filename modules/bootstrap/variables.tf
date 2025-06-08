/*
 Copyright (c) 2023, Deductive AI, Inc. All rights reserved.

 This software is the confidential and proprietary information of
 Deductive AI, Inc. You shall not disclose such confidential
 information and shall use it only in accordance with the terms of
 the license agreement you entered into with Deductive AI, Inc.
*/

variable "role_info" {
  description = "Information required for role creation"
  type = object({
    resource_prefix          = optional(string, "Deductive")
    external_id              = optional(string, null)
    deductive_aws_account_id = optional(string, null)
  })
  default = {}
}

variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "tenant" {
  description = "Tenant identifier for multi-tenant deployments"
  type        = string
}
