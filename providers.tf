/*
 Copyright (c) 2023, Deductive AI, Inc. All rights reserved.

 This software is the confidential and proprietary information of
 Deductive AI, Inc. You shall not disclose such confidential
 information and shall use it only in accordance with the terms of
 the license agreement you entered into with Deductive AI, Inc.
*/
terraform {
  # backend "s3" {
  #   bucket  = "deductive-ai-iac"
  #   key     = "terraform.tfstate"
  #   region  = "us-west-1"
  #   encrypt = true
  # }
}

provider "aws" {
  region = var.region
  profile = var.aws_profile
}