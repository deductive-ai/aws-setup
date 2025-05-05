/*
 Copyright (c) 2023, Deductive AI, Inc. All rights reserved.

 This software is the confidential and proprietary information of
 Deductive AI, Inc. You shall not disclose such confidential
 information and shall use it only in accordance with the terms of
 the license agreement you entered into with Deductive AI, Inc.
*/

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

variable "resource_prefix" {
  description = "Prefix to add to resource names for uniqueness"
  type        = string
  default     = "Deductive"
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "deductive_aws_account_id" {
  description = "Deductive AI's AWS account ID for cross-account permissions"
  type        = string
  sensitive   = true
}

variable "external_id" {
  description = "External ID for secure cross-account role assumption (optional but recommended for security)"
  type        = string
  default     = "" # Making it optional by providing a default empty value
  sensitive   = true
}

variable "use_external_id" {
  description = "Whether to use external ID for cross-account role assumption"
  type        = bool
  default     = false
}

locals {
  # Standardized tags
  default_tags = {
    creator = "deductive-ai"
  }

  # Merge default tags with provided tags
  tags = merge(local.default_tags, var.tags)
}
