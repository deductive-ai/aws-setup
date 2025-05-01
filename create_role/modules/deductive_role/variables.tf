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

locals {
  # Constants
  deductive_aws_account_id = "590183993904"

  # Standardized tags
  default_tags = {
    creator = "deductive-ai"
  }

  # Merge default tags with provided tags
  tags = merge(local.default_tags, var.tags)
}
