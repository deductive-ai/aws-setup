/*
 Copyright (c) 2023, Deductive AI, Inc. All rights reserved.

 This software is the confidential and proprietary information of
 Deductive AI, Inc. You shall not disclose such confidential
 information and shall use it only in accordance with the terms of
 the license agreement you entered into with Deductive AI, Inc.
*/

# The purpose of this module is to create a role for DeductiveAI in Customer's
# AWS account. This role can then be assumed by DeductiveAI to deploy services
# necessary for its operations in the Customer's AWS account.
#
# This Terraform module creates the following resources:
# 1. DeductiveAssumeRole - The main role that DeductiveAI assumes to manage resources
#    - Permissions: EC2, EKS, IAM, ACM, S3, Secrets Manager, and other AWS services
#    - Purpose: Allows DeductiveAI to provision and manage the infrastructure
#
# 2. EKSClusterRole - Role for EKS cluster with permissions to manage EKS services
#    - Permissions: AmazonEKSClusterPolicy, AmazonEKSServicePolicy
#    - Purpose: Allows the EKS control plane to manage AWS resources on behalf of the cluster
#
# 3. EC2Role - Role for EC2 instances that run as worker nodes in the EKS cluster
#    - Permissions: AmazonEKSWorkerNodePolicy, AmazonEKS_CNI_Policy, 
#      AmazonEC2ContainerRegistryReadOnly, AmazonEBSCSIDriverPolicy
#    - Purpose: Allows worker nodes to join the cluster and access required AWS services
#
# 4. SecretsReaderRole - Role for reading secrets from AWS Secrets Manager
#    - Permissions: GetSecretValue, DescribeSecret, AssumeRole (EC2Role)
#    - Purpose: Allows Kubernetes pods to read secrets from AWS Secrets Manager
#
# 5. SecretsWriterReaderRole - Role for reading and writing secrets to AWS Secrets Manager
#    - Permissions: GetSecretValue, DescribeSecret, CreateSecret, PutSecretValue, UpdateSecret
#    - Purpose: Allows Kubernetes pods to read and write secrets to AWS Secrets Manager
#
# Each role has specific policies attached that grant the minimum necessary permissions
# for DeductiveAI to operate effectively while maintaining security best practices.
#
# The trust relationships are configured as follows:
# - DeductiveAssumeRole: Trusted by DeductiveAI AWS account
# - EKSClusterRole: Trusted by EKS service
# - EC2Role: Trusted by EC2 service and SecretsReaderRole
# - SecretsReaderRole: Initially trusted by EKS service, later updated for OIDC
# - SecretsWriterReaderRole: Initially trusted by EKS service, later updated for OIDC

provider "aws" {
  region  = var.region
  profile = var.aws_profile
}

data "aws_caller_identity" "current" {}

# Define the assume role policy document
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.deductive_aws_account_id}:root"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# Define the main policy document for Deductive operations
data "aws_iam_policy_document" "deductive_policy" {
  # Read-only permissions for various AWS services
  statement {
    effect = "Allow"
    actions = [
      # EC2 Read-Only Actions
      "ec2:Describe*",
      "ec2:Get*",
      "ec2:List*",
      # ELB Read-Only Actions
      "elasticloadbalancing:Describe*",
      # EKS Read-Only Actions
      "eks:Describe*",
      "eks:List*",
      # IAM Read-Only Actions
      "iam:GetRole",
      "iam:GetInstanceProfile",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:GetRolePolicy",
      "iam:ListAttachedRolePolicies",
      "iam:ListEntitiesForPolicy",
      "iam:ListInstanceProfilesForRole",
      "iam:ListRolePolicies",
      "iam:ListPolicyVersions",
      "iam:CreatePolicyVersion",
      # For nodegroup creation
      "iam:CreateServiceLinkedRole",
      # ACM Read-Only Actions
      "acm:Describe*",
      "acm:List*"
    ]
    resources = ["*"]
  }

  # Create Deductive SSL certificate for SSO
  statement {
    effect = "Allow"
    actions = [
      "acm:RequestCertificate"
    ]
    resources = ["arn:aws:acm:*:${data.aws_caller_identity.current.account_id}:certificate/*"]
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/creator"
      values   = ["deductive-ai"]
    }
  }

  # Create permission to run instances
  statement {
    effect = "Allow"
    actions = [
      "ec2:RebootInstances",
      "ec2:RunInstances",
    ]
    resources = [
      "arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:*/*",
      "arn:aws:ec2:*::image/ami-*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/creator"
      values   = ["deductive-ai"]
    }
  }

  # ACM certificate management
  statement {
    effect = "Allow"
    actions = [
      "acm:DescribeCertificate",
      "acm:DeleteCertificate",
      "acm:AddTagsToCertificate",
      "acm:RemoveTagsFromCertificate",
      "acm:ListTagsForCertificate"
    ]
    resources = ["arn:aws:acm:*:${data.aws_caller_identity.current.account_id}:certificate/*"]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/creator"
      values   = ["deductive-ai"]
    }
  }

  # Allow permissions to create resources for EC2 and VPC
  statement {
    effect = "Allow"
    actions = [
      "ec2:AllocateAddress",
      "ec2:CreateLaunchTemplate",
      "ec2:CreateInternetGateway",
      "ec2:CreateNatGateway",
      "ec2:CreateVpc",
      "ec2:CreateVpcPeeringConnection",
      "ec2:CreateSecurityGroup",
      "ec2:CreateSubnet",
      "ec2:CreateRouteTable",
      "ec2:CreateTags",
      "ec2:CreateVolume",
      "ec2:DeleteVolume",
      "ec2:AttachVolume",
      "ec2:DetachVolume",
      "ec2:ModifyVolume",
      "ec2:DescribeVolumes"
    ]
    resources = ["arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:*/*"]
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/creator"
      values   = ["deductive-ai"]
    }
  }

  # EC2 and VPC management
  statement {
    effect = "Allow"
    actions = [
      # Creation of Resources
      "ec2:AssociateRouteTable",
      "ec2:AttachInternetGateway",
      "ec2:CreateKeyPair",
      "ec2:CreateNatGateway",
      "ec2:CreateRoute",
      "ec2:CreateSecurityGroup",
      "ec2:CreateSubnet",
      "ec2:CreateRouteTable",
      # Required to terminate, reboot, stop and start instances
      "ec2:TerminateInstances",
      "ec2:RebootInstances",
      "ec2:StopInstances",
      "ec2:StartInstances",
      # Required for modifications of the resources
      "ec2:Modify*",
      "ec2:Delete*",
      "ec2:Disassociate*",
      "ec2:Detach*",
      "ec2:Unassign*",
      "ec2:ReleaseAddress"
    ]
    resources = ["arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:*/*"]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/creator"
      values   = ["deductive-ai"]
    }
  }

  # EIP management
  statement {
    effect = "Allow"
    actions = [
      "ec2:DisassociateAddress"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/creator"
      values   = ["deductive-ai"]
    }
  }

  # Security group management
  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateTags",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:DeleteSecurityGroup",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:AuthorizeSecurityGroupEgress"
    ]
    resources = ["arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:security-group/*"]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/creator"
      values   = ["deductive-ai"]
    }
  }

  # EKS management
  statement {
    effect = "Allow"
    actions = [
      "eks:Create*",
      "eks:Delete*",
      "eks:Update*",
      "eks:DeregisterCluster",
      "eks:RegisterCluster",
      "eks:TagResource",
      "eks:UntagResource"
    ]
    resources = ["arn:aws:eks:*:${data.aws_caller_identity.current.account_id}:*/*"]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/creator"
      values   = ["deductive-ai"]
    }
  }

  # S3 bucket management
  statement {
    effect = "Allow"
    actions = [
      "s3:CreateBucket",
      "s3:List*",
      "s3:Get*",
      "s3:Put*",
      "s3:Delete*",
    ]
    resources = ["arn:aws:s3:::deductiveai-*"]
  }

  # IAM PassRole and UntagRole
  statement {
    effect = "Allow"
    actions = [
      "iam:PassRole",
      "iam:UntagRole",
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/*deductive*",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/*Deductive*"
    ]
  }

  # OpenIDConnect provider listing
  statement {
    effect = "Allow"
    actions = [
      "iam:ListOpenIDConnectProviders"
    ]
    resources = ["*"]
  }

  # OpenIDConnect provider management
  statement {
    effect = "Allow"
    actions = [
      "iam:CreateOpenIDConnectProvider",
      "iam:GetOpenIDConnectProvider",
      "iam:DeleteOpenIDConnectProvider",
      "iam:TagOpenIDConnectProvider",
    ]
    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/oidc.eks.*.amazonaws.com/id/*"]
  }

  # IAM role and policy management permissions
  statement {
    effect = "Allow"
    actions = [
      "iam:AddRoleToInstanceProfile",
      "iam:AttachRolePolicy",
      "iam:CreateInstanceProfile",
      "iam:CreatePolicy",
      "iam:CreateRole",
      "iam:CreateServiceLinkedRole",
      "iam:DeleteInstanceProfile",
      "iam:DeleteRole",
      "iam:DeleteRolePolicy",
      "iam:DeletePolicy",
      "iam:DeletePolicyVersion",
      "iam:DetachRolePolicy",
      "iam:RemoveRoleFromInstanceProfile",
      "iam:TagPolicy",
      "iam:TagRole",
      "iam:UpdateAssumeRolePolicy"
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/*deductive*",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/*Deductive*",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/*deductive*",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/*Deductive*",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:instance-profile/*deductive*",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:instance-profile/*Deductive*",
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/creator"
      values   = ["deductive-ai"]
    }
  }

  # Explicitly deny attaching admin policies
  statement {
    effect = "Deny"
    actions = [
      "iam:AttachRolePolicy",
      "iam:PutRolePolicy"
    ]
    resources = ["*"]
    condition {
      test     = "ArnLike"
      variable = "iam:PolicyArn"
      values = [
        "arn:aws:iam::aws:policy/AdministratorAccess",
        "arn:aws:iam::aws:policy/*Admin*",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/*Admin*"
      ]
    }
  }

  # Prevent creating policies with * permissions
  statement {
    effect = "Deny"
    actions = [
      "iam:CreatePolicy",
      "iam:CreatePolicyVersion"
    ]
    resources = ["*"]
    condition {
      test     = "ForAnyValue:StringLike"
      variable = "iam:PolicyDocument"
      values = [
        "*\"Action\":[\"*\"]",
        "*\"Action\":\"*\"",
        "*\"Action\":[\"iam:*\"]",
        "*\"Action\":\"iam:*\""
      ]
    }
  }
}

# Define the secrets management policy document
# This is just a policy document definition, not a resource in AWS
data "aws_iam_policy_document" "secrets_management_policy" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:CreateSecret",
      "secretsmanager:PutSecretValue"
    ]
    resources = [aws_secretsmanager_secret.deductive_secrets.arn]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/creator"
      values   = ["deductive-ai"]
    }
  }
}

# Create a standalone IAM policy for EKS pods to access secrets
# This creates a reusable policy that can be attached to multiple roles
resource "aws_iam_policy" "secret_reader_policy" {
  name        = "${var.resource_prefix}AISecretsReaderPolicy"
  description = "Policy to allow read access to DeductiveAISecrets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
        ]
        Resource = aws_secretsmanager_secret.deductive_secrets.arn
        Condition = {
          StringEquals = {
            "aws:ResourceTag/creator" : "deductive-ai"
          }
        }
      }
    ]
  })
  tags = local.tags
}

# Create the IAM role with inline policies
resource "aws_iam_role" "deductive_role" {
  name               = "${var.resource_prefix}AssumeRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  tags               = local.tags
}

# Create an inline policy for Deductive operations
# This policy is embedded directly in the deductive_role
resource "aws_iam_role_policy" "deductive_policy" {
  name   = "${var.resource_prefix}Policy"
  role   = aws_iam_role.deductive_role.id
  policy = data.aws_iam_policy_document.deductive_policy.json
}

# Create an inline secrets management policy
# This policy is embedded directly in the deductive_role
resource "aws_iam_role_policy" "secrets_management_policy" {
  name   = "${var.resource_prefix}SecretsManagementPolicy"
  role   = aws_iam_role.deductive_role.id
  policy = data.aws_iam_policy_document.secrets_management_policy.json
}

# Attach the AWS-managed EBS CSI Driver policy to the role
resource "aws_iam_role_policy_attachment" "ebs_csi_driver_policy_attachment" {
  role       = aws_iam_role.deductive_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# Create the secrets manager secret
resource "aws_secretsmanager_secret" "deductive_secrets" {
  name        = "${var.resource_prefix}AISecrets1"
  description = "Secrets for Deductive AI application"
  tags        = local.tags
}

# Create EKS cluster role
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.resource_prefix}EKSClusterRole"
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
  tags = local.tags
}

# Attach EKS cluster policies using for_each
resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attachments" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  ])

  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = each.value
}

# Create EC2 role for worker nodes
resource "aws_iam_role" "ec2_role" {
  name = "${var.resource_prefix}EC2Role"
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
  tags = local.tags
}

# Attach policies to EC2 role using for_each
resource "aws_iam_role_policy_attachment" "ec2_policy_attachments" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess",
    "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  ])

  role       = aws_iam_role.ec2_role.name
  policy_arn = each.value
}

# Create metrics query policy
resource "aws_iam_policy" "query_metrics_policy" {
  name        = "${var.resource_prefix}QueryMetricsPolicy"
  description = "Policy to allow querying CloudWatch metrics"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:GetMetricData",
          "cloudwatch:ListMetrics",
          "cloudwatch:GetMetricStatistics"
        ]
        Resource = "*"
      }
    ]
  })
  tags = local.tags
}

# Attach metrics query policy to EC2 role
resource "aws_iam_role_policy_attachment" "ec2_query_metrics_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.query_metrics_policy.arn
}

# Create S3 ClickHouse policy
resource "aws_iam_policy" "s3_clickhouse_policy" {
  name        = "${var.resource_prefix}S3ClickHousePolicy"
  description = "Policy for ClickHouse to access S3"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::deductiveai-*",
          "arn:aws:s3:::deductiveai-*/*"
        ]
      }
    ]
  })
  tags = local.tags
}

# Create secrets reader role with placeholder trust policy
resource "aws_iam_role" "secrets_reader_role" {
  name = "${var.resource_prefix}SecretsReaderRole"
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
  tags = local.tags
}

# Attach policies to secrets reader role using for_each
resource "aws_iam_role_policy_attachment" "secrets_reader_policy_attachments" {
  for_each = toset([
    aws_iam_policy.secrets_reader_assume_ec2_policy.arn,
    aws_iam_policy.secret_reader_policy.arn
  ])

  role       = aws_iam_role.secrets_reader_role.name
  policy_arn = each.value
}

# Create secrets writer/reader role with placeholder trust policy
resource "aws_iam_role" "secrets_writer_reader_role" {
  name = "${var.resource_prefix}SecretsWriterReaderRole"
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
  tags = local.tags
}

# Attach policy to secrets writer/reader role
resource "aws_iam_role_policy_attachment" "secrets_writer_reader_policy_attachment" {
  role       = aws_iam_role.secrets_writer_reader_role.name
  policy_arn = aws_iam_policy.secrets_writer_reader_policy.arn
}

# Create a policy for secrets reader role to assume EC2 role
resource "aws_iam_policy" "secrets_reader_assume_ec2_policy" {
  name        = "${var.resource_prefix}SecretsReaderAssumeEC2Policy"
  description = "Policy to allow SecretsReaderRole to assume EC2 instance role"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sts:AssumeRole"
        Resource = aws_iam_role.ec2_role.arn
      }
    ]
  })
  tags = local.tags
}

# Create a policy for secrets writer/reader
resource "aws_iam_policy" "secrets_writer_reader_policy" {
  name        = "${var.resource_prefix}SecretsWriterReaderPolicy"
  description = "Policy to allow writing and reading secrets"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:CreateSecret",
          "secretsmanager:PutSecretValue",
          "secretsmanager:UpdateSecret"
        ]
        Resource = aws_secretsmanager_secret.deductive_secrets.arn
      }
    ]
  })
  tags = local.tags
}

