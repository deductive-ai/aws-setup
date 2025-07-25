/*
 Copyright (c) 2023, Deductive AI, Inc. All rights reserved.

 This software is the confidential and proprietary information of
 Deductive AI, Inc. You shall not disclose such confidential
 information and shall use it only in accordance with the terms of
 the license agreement you entered into with Deductive AI, Inc.
*/

# The purpose of this module is to create a role for Deductive AI to perform aws resource provisioning.
# This role can then be assumed by Deductive AI to deploy services
# necessary for its operations in the Customer's AWS account.

# Use local variables to unpack and set defaults for the role_info input
locals {
  resource_prefix          = var.role_info.resource_prefix
  external_id              = var.role_info.external_id
  deductive_aws_account_id = var.role_info.deductive_aws_account_id != null ? var.role_info.deductive_aws_account_id : "590183993904"
}

###########################################
# IAM ROLES AND POLICY ATTACHMENTS
###########################################

# Create the main Deductive role
resource "aws_iam_role" "deductive_role" {
  // The name is actually DeductiveAIAssumeRole-<tenant> for example DeductiveAIAssumeRole-deductiveai
  name               = "${local.resource_prefix}AssumeRole-${var.tenant}"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  tags = merge(
    var.additional_tags,
    {
      creator = "deductive-ai"
    }
  )
}

# Attach the Deductive policy to the role
# This policy provides comprehensive AWS service permissions for infrastructure management,
# including EC2, EKS, IAM, S3, ELB, and WAF services with appropriate security controls
resource "aws_iam_role_policy" "deductive_policy" {
  name   = "${local.resource_prefix}Policy"
  role   = aws_iam_role.deductive_role.id
  policy = data.aws_iam_policy_document.deductive_policy.json
}

# Attach the secrets management policy to the role
# This policy grants permissions to manage AWS Secrets Manager resources
# with scope limited to secrets prefixed with 'deductiveai-'
resource "aws_iam_role_policy" "secrets_management_policy" {
  name   = "${local.resource_prefix}SecretsManagementPolicy"
  role   = aws_iam_role.deductive_role.id
  policy = data.aws_iam_policy_document.secrets_management_policy.json
}

# Attach the EBS CSI driver policy to the role
# This AWS managed policy provides the necessary permissions for the EBS CSI driver
# to provision and manage EBS volumes within EKS clusters
resource "aws_iam_role_policy_attachment" "ebs_csi_driver_policy_attachment" {
  role       = aws_iam_role.deductive_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}
