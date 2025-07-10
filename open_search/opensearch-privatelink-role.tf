/*
 Copyright (c) 2023, Deductive AI, Inc. All rights reserved.

 This software is the confidential and proprietary information of
 Deductive AI, Inc. You shall not disclose such confidential
 information and shall use it only in accordance with the terms of
 the license agreement you entered into with Deductive AI, Inc.
*/

/*
 To enable Deductive AI to access your OpenSearch domain over PrivateLink, you need to:

 1. Ensure you have a VPC endpoint set up for OpenSearch (see opensearch-vpc-endpoint.tf for reference)
 2. Apply this configuration to create an IAM role
 3. Share the outputs with Deductive AI

 Deductive AI will use this information to:
 - Assume the IAM role from our EC2 instances
 - Connect to your OpenSearch domain over PrivateLink
 - Verify the correct VPC endpoint and AWS account

 Required information:
 - OpenSearch domain name
 - AWS region where OpenSearch is deployed
 - VPC endpoint ID for OpenSearch
*/

#################################################
# Variables
#################################################
variable "opensearch_domain_name" {
  description = "Name of your OpenSearch domain"
  type        = string
}

variable "tenant" {
  description = "Name of the tenant"
  type        = string
}

variable "opensearch_aws_region" {
  description = "AWS region where your OpenSearch domain exists"
  type        = string
}

variable "vpc_endpoint_id" {
  description = "ID of your OpenSearch VPC endpoint"
  type        = string
}

#################################################
# Data Sources
#################################################
data "aws_caller_identity" "current" {}

#################################################
# Resources
#################################################
# Create IAM role for Deductive AI
resource "aws_iam_role" "deductive_access" {
  name = "DeductiveAIOpenSearchRole-${var.tenant}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::590183993904:role/DeductiveAIEC2Role-${var.tenant}"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Create inline policy for OpenSearch access
resource "aws_iam_role_policy" "opensearch_access" {
  name = "DeductiveAIOpenSearchPolicy"
  role = aws_iam_role.deductive_access.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "es:ESHttp*",
          "es:Describe*",
          "es:List*"
        ]
        Resource = [
          "arn:aws:es:${var.opensearch_aws_region}:${data.aws_caller_identity.current.account_id}:domain/${var.opensearch_domain_name}",
          "arn:aws:es:${var.opensearch_aws_region}:${data.aws_caller_identity.current.account_id}:domain/${var.opensearch_domain_name}/*"
        ]
      }
    ]
  })
}

#################################################
# Outputs
#################################################
output "deductive_access_info" {
  description = "Information needed by Deductive AI to access your OpenSearch domain"
  value = {
    role_arn          = aws_iam_role.deductive_access.arn
    opensearch_domain = var.opensearch_domain_name
    aws_region        = var.opensearch_aws_region
    vpc_endpoint_id   = var.vpc_endpoint_id
    aws_account_id    = data.aws_caller_identity.current.account_id
  }
}
