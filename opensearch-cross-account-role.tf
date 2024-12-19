/*
 Copyright (c) 2023, Deductive AI, Inc. All rights reserved.

 This software is the confidential and proprietary information of
 Deductive AI, Inc. You shall not disclose such confidential
 information and shall use it only in accordance with the terms of
 the license agreement you entered into with Deductive AI, Inc.
*/

#################################################
# Variables
#################################################
variable "opensearch_domain_name" {
  description = "Name of the OpenSearch domain"
  type        = string
}
variable "opensearch_aws_region" {
  description = "AWS region where the OpenSearch domain exists"
  type        = string
}
variable "trusted_account_id" {
  description = "AWS Account ID that contains the role"
  type        = string
}
variable "trusted_cross_account_role_name" {
  description = "Name of the role in the trusted account that needs access"
  type        = string
  default     = "*DeductiveAIEC2Role*"
}
#################################################
# Data Sources
#################################################
data "aws_caller_identity" "current" {}
#################################################
# Resources
#################################################
# Create a new IAM role
resource "aws_iam_role" "opensearch_cross_account" {
  name = "DeductiveAIOpenSearchCrossAccountRole"

  # Allow the specified role to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.trusted_account_id}:role/${var.trusted_cross_account_role_name}"
        }
        Action    = "sts:AssumeRole"
        Condition = {}
      }
    ]
  })
}
# Create the OpenSearch access policy
resource "aws_iam_policy" "opensearch_access" {
  name        = "DeductiveAIOpenSearchCrossAccountPolicy"
  description = "Policy for OpenSearch search and read operations"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          # General HTTP operations
          "es:ESHttp*",
          # Domain-level metadata
          "es:Describe*",
          "es:List*"
        ]
        Resource = [
          # Domain root
          "arn:aws:es:${var.opensearch_aws_region}:${data.aws_caller_identity.current.account_id}:domain/${var.opensearch_domain_name}",
          # All sub-resources
          "arn:aws:es:${var.opensearch_aws_region}:${data.aws_caller_identity.current.account_id}:domain/${var.opensearch_domain_name}/*"
        ]
      }
    ]
  })
}
# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "opensearch_attachment" {
  role       = aws_iam_role.opensearch_cross_account.name
  policy_arn = aws_iam_policy.opensearch_access.arn
}
#################################################
# Outputs
#################################################
output "role_arn" {
  description = "ARN of the created role"
  value       = aws_iam_role.opensearch_cross_account.arn
}
output "policy_arn" {
  description = "ARN of the created policy"
  value       = aws_iam_policy.opensearch_access.arn
}
