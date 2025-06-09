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
  name               = "${local.resource_prefix}AssumeRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  tags = merge(
    var.additional_tags,
    {
      creator = "deductive-ai"
    }
  )
}

# Attach the Deductive policy to the role
resource "aws_iam_role_policy" "deductive_policy" {
  name   = "${local.resource_prefix}Policy"
  role   = aws_iam_role.deductive_role.id
  policy = data.aws_iam_policy_document.deductive_policy.json
}

# Attach the secrets management policy to the role
resource "aws_iam_role_policy" "secrets_management_policy" {
  name   = "${local.resource_prefix}SecretsManagementPolicy"
  role   = aws_iam_role.deductive_role.id
  policy = data.aws_iam_policy_document.secrets_management_policy.json
}

# Attach the EBS CSI driver policy to the role
resource "aws_iam_role_policy_attachment" "ebs_csi_driver_policy_attachment" {
  role       = aws_iam_role.deductive_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# Create the EKS cluster role
resource "aws_iam_role" "eks_cluster_role" {
  name = "${local.resource_prefix}EKSClusterRole-${var.tenant}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    var.additional_tags,
    {
      creator = "deductive-ai"
    }
  )
}

# Attach the necessary policies to the EKS cluster role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attachments" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy",
    "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
  ])

  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = each.value
}

# Create the EC2 role for worker nodes
resource "aws_iam_role" "ec2_role" {
  name = "${local.resource_prefix}EC2Role-${var.tenant}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    var.additional_tags,
    {
      creator = "deductive-ai"
    }
  )
}

# Attach the necessary policies to the EC2 role
resource "aws_iam_role_policy_attachment" "ec2_policy_attachments" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess",
    "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy",
    # For Karpenter to manage spot instances https://karpenter.sh/docs/getting-started/migrating-from-cas/
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ])

  role       = aws_iam_role.ec2_role.name
  policy_arn = each.value
}



# Attach custom policy to ec2 role
resource "aws_iam_role_policy" "ec2_custom_policy" {
  name   = "${local.resource_prefix}EC2CustomPolicy"
  role   = aws_iam_role.ec2_role.id
  policy = data.aws_iam_policy_document.ec2_custom_policy_document.json
}
