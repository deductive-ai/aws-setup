/*
 Copyright (c) 2023, Deductive AI, Inc. All rights reserved.

 This software is the confidential and proprietary information of
 Deductive AI, Inc. You shall not disclose such confidential
 information and shall use it only in accordance with the terms of
 the license agreement you entered into with Deductive AI, Inc.
*/

# The purpose of this script is to create a role for DeductiveAI in Customer's
# AWS account. This role can then be assumed by DeductiveAI to deploy services
# necessary for its operations in the Customer's AWS account.
# terraform apply -var="region=us-east-2" -var="aws_profile=myprofile"
#
# The script outputs the ARN for the newly created role and that needs to be
# shared back to Deductive.

variable "region" {
  description = "The AWS region to create in"
  type        = string
  default     = "us-east-2"
}

variable "aws_profile" {
  description = "AWS profile to use as credential"
  type        = string
  default     = "default"
}

variable "deductive_aws_account_id" {
  description = "The Deductive AWS account ID"
  type        = string
  default     = "590183993904"
}

provider "aws" {
  region  = var.region
  profile = var.aws_profile
}

data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "deductive_policy" {
  name        = "DeductivePolicy"
  description = "Policy for deductive to manage EC2, EKS and other services"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        # Restrict to read-only actions on AWS services
        Effect = "Allow",
        Action = [
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
        ],
        Resource = "*",
      },
      # Create Deductive SSL certificate for SSO
      {
        Effect = "Allow",
        Action = [
          "acm:RequestCertificate"
        ],
        Resource = "arn:aws:acm:*:${data.aws_caller_identity.current.account_id}:certificate/*",
        Condition = {
          "StringEquals" : {
            "aws:RequestTag/creator" : "deductive-ai"
          }
        }
      },
      # Create permission to run instances
      {
        Effect = "Allow",
        Action = [
          "ec2:RebootInstances",
          "ec2:RunInstances",
        ],
        Resource = [
          "arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:*/*",
          "arn:aws:ec2:*::image/ami-*"
        ],
        Condition = {
          "StringEquals" : {
            "aws:ResourceTag/creator" : "deductive-ai"
          }
        }
      },
      {
        Effect = "Allow",
        Action = [
          "acm:DescribeCertificate",
          "acm:DeleteCertificate",
          "acm:AddTagsToCertificate",
          "acm:RemoveTagsFromCertificate",
          "acm:ListTagsForCertificate"
        ],
        Resource = "arn:aws:acm:*:${data.aws_caller_identity.current.account_id}:certificate/*",
        Condition = {
          "StringEquals" : {
            "aws:ResourceTag/creator" : "deductive-ai"
          }
        }
      },
      # Allow permissions to create resources for EC2 and VPC
      {
        Effect = "Allow",
        Action = [
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
        ],
        Resource = [
          "arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:*/*"
        ],
        Condition = {
          "StringEquals" : {
            "aws:RequestTag/creator" : "deductive-ai"
          }
        }
      },
      {
        Effect = "Allow",
        Action = [
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
        ],
        Resource = [
          "arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:*/*"
        ],
        Condition = {
          "StringEquals" : {
            "aws:ResourceTag/creator" : "deductive-ai",
          }
        }
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:DisassociateAddress"
        ],
        # The Amazon Resource Name (ARN) format for an Elastic IP (EIP) in AWS does not follow the
        # typical resource-specific ARN format used for other resources like instances, volumes, etc.
        # This is because EIPs do not have a direct ARN representation in the same way other EC2 resources do.
        # Instead, permissions for actions involving EIPs, like ec2:DisassociateAddress, are generally specified
        # with wildcards and conditions.
        Resource = "*",
        Condition = {
          "StringEquals" : {
            "aws:ResourceTag/creator" : "deductive-ai"
          }
        }
      },
      {
        Effect = "Allow",
        Action = [
          # Creation of Resources
          "ec2:CreateTags",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:DeleteSecurityGroup",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress"
        ],
        Resource = "arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:security-group/*",
        Condition = {
          "StringEquals" : {
            "aws:ResourceTag/creator" : "deductive-ai",
          }
        }
      },
      # Permissions for Creation and Mutation of EKS resources
      {
        Effect = "Allow",
        Action = [
          "eks:Create*",
          "eks:Delete*",
          "eks:Update*",
          "eks:DeregisterCluster",
          "eks:RegisterCluster",
          "eks:TagResource",
          "eks:UntagResource"
        ],
        Resource = [
          "arn:aws:eks:*:${data.aws_caller_identity.current.account_id}:*/*"
        ],
        Condition = {
          "StringEquals" : {
            "aws:ResourceTag/creator" : "deductive-ai"
          }
        }
      },
      {
        Effect = "Allow",
        Action = [
          "kinesis:*",
        ],
        Resource = "arn:aws:kinesis:*:*:stream/*_deductiveai_*",
      },
      {
        Effect = "Allow",
        Action = [
          "s3:CreateBucket",
          "s3:List*",
          "s3:Get*",
          "s3:Put*",
          "s3:Delete*",
        ],
        Resource = [
          "arn:aws:s3:::deductiveai-*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "iam:PassRole",
          "iam:UntagRole",
        ],
        Resource = [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/*deductive*",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/*Deductive*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
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
        ],
        Resource = [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/*deductive*",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/*Deductive*",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/*deductive*",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/*Deductive*",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:instance-profile/*deductive*",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:instance-profile/*Deductive*",
        ],
        Condition = {
          "StringEquals" : {
            "aws:ResourceTag/creator" : "deductive-ai"
          }
        }
      },
      {
        Effect = "Allow",
        Action = [
          "iam:ListOpenIDConnectProviders"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "iam:CreateOpenIDConnectProvider",
          "iam:GetOpenIDConnectProvider",
          "iam:DeleteOpenIDConnectProvider",
          "iam:TagOpenIDConnectProvider",
        ],
        Resource = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/oidc.eks.*.amazonaws.com/id/*"
      }
    ]
  })
}

resource "aws_iam_role" "deductive_role" {
  name = "DeductiveAssumeRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${var.deductive_aws_account_id}:root"
        },
        Action = "sts:AssumeRole",
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "role_policy_attachment" {
  role       = aws_iam_role.deductive_role.name
  policy_arn = aws_iam_policy.deductive_policy.arn
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver_policy_attachment" {
  role       = aws_iam_role.deductive_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_secretsmanager_secret" "deductive_secrets" {
  name        = "DeductiveAISecrets"
  description = "Secrets for Deductive AI application"

  tags = {
    creator = "deductive-ai"
  }
}

# Add necessary IAM policy to allow EKS pods to access the secret
resource "aws_iam_policy" "secret_reader_policy" {
  name        = "DeductiveAISecretsReaderPolicy"
  description = "Policy to allow access to DeductiveAISecrets"

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

  tags = {
    creator = "deductive-ai"
  }
}

# Attach the policy to the existing DeductiveRole
resource "aws_iam_role_policy_attachment" "secret_reader_policy_attachment" {
  role       = aws_iam_role.deductive_role.name
  policy_arn = aws_iam_policy.secret_reader_policy.arn
}

# create writer-reader policy
resource "aws_iam_policy" "secret_writer_reader_policy" {
  name        = "DeductiveAISecretsWriterReaderPolicy"
  description = "Policy to allow read and writer secrets to DeductiveAISecrets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:CreateSecret",
          "secretsmanager:PutSecretValue"
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

  tags = {
    creator = "deductive-ai"
  }
}

resource "aws_iam_role_policy_attachment" "secret_writer_reader_policy_attachment" {
  role       = aws_iam_role.deductive_role.name
  policy_arn = aws_iam_policy.secret_writer_reader_policy.arn
}


output "deductive_role_arn" {
  description = "The ARN of the Deductive role"
  value       = aws_iam_role.deductive_role.arn
}

output "deductive_ai_secrets_arn" {
  description = "The ARN of AWS DeductiveAISecrets"
  value       = aws_secretsmanager_secret.deductive_secrets.arn
}

output "secret_reader_policy_arn" {
  description = "The ARN of the secrets access policy"
  value       = aws_iam_policy.secret_reader_policy.arn
}
