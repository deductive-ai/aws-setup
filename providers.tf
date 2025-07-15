/*
 Copyright (c) 2023, Deductive AI, Inc. All rights reserved.

 This software is the confidential and proprietary information of
 Deductive AI, Inc. You shall not disclose such confidential
 information and shall use it only in accordance with the terms of
 the license agreement you entered into with Deductive AI, Inc.
*/
terraform {
  # Backend configuration:
  # Default: terraform init (uses local backend)
  # S3: terraform init -backend-config=backend-s3.conf
  backend "s3" {}
}

provider "aws" {
  region  = var.region
  profile = var.aws_profile
}