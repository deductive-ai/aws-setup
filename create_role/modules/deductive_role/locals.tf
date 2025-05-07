/*
 Copyright (c) 2023, Deductive AI, Inc. All rights reserved.

 This software is the confidential and proprietary information of
 Deductive AI, Inc. You shall not disclose such confidential
 information and shall use it only in accordance with the terms of
 the license agreement you entered into with Deductive AI, Inc.
*/

locals {
  # Standardized tags
  default_tags = {
    creator = "deductive-ai"
  }

  # Merge default tags with provided tags
  resource_tags = merge(local.default_tags, var.additional_tags)
  
  # Default Deductive AWS account ID (can be overridden by var.deductive_aws_account_id)
  deductive_aws_account_id = var.deductive_aws_account_id != null ? var.deductive_aws_account_id : "590183993904"
} 