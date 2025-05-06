/*
 Copyright (c) 2023, Deductive AI, Inc. All rights reserved.

 This software is the confidential and proprietary information of
 Deductive AI, Inc. You shall not disclose such confidential
 information and shall use it only in accordance with the terms of
 the license agreement you entered into with Deductive AI, Inc.
*/

variable "resource_prefix" {
  description = "Prefix to add to resource names for uniqueness"
  type        = string
  default     = "Deductive"
}

variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "deductive_aws_account_id" {
  description = "Deductive AI's AWS account ID for cross-account permissions (will be provided by Deductive)"
  type        = string
  sensitive   = true
}

variable "external_id" {
  description = "External ID for secure cross-account role assumption (optional but recommended for security)"
  type        = string
  default     = null
  nullable    = true
  sensitive   = true
}
