/*
 Copyright (c) 2023, Deductive AI, Inc. All rights reserved.

 This software is the confidential and proprietary information of
 Deductive AI, Inc. You shall not disclose such confidential
 information and shall use it only in accordance with the terms of
 the license agreement you entered into with Deductive AI, Inc.
*/
data "aws_caller_identity" "current" {}

###########################################
# POLICY DOCUMENTS (IAM Policy Definitions)
###########################################

# Define the assume role policy document with optional external ID
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.deductive_aws_account_id}:root"]
    }
    actions = ["sts:AssumeRole"]

    # Only include the condition if external_id is set to avoid the confused deputy problem
    dynamic "condition" {
      for_each = local.external_id != null ? toset(["include"]) : toset([])
      content {
        test     = "StringEquals"
        variable = "sts:ExternalId"
        values   = [local.external_id]
      }
    }
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

  statement {
    effect = "Allow"
    actions = [
      "ec2:RunInstances",
    ]
    resources = [
      "arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:launch-template/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/creator"
      values   = ["deductive-ai"]
    }
  }

  # Perform RunInstances against the instance and spot-instances-request resources
  statement {
    effect = "Allow"
    actions = [
      "ec2:RunInstances",
    ]
    resources = [
      "arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:instance/*",
      "arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:spot-instances-request/*",
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/creator"
      values   = ["deductive-ai"]
    }
  }

  # Second statement is required: RunInstances also requires the
  # AMI, subnets, SGs, etc.
  statement {
    sid     = "RunViaAllowedTemplateReferencedResources"
    effect  = "Allow"
    actions = ["ec2:RunInstances"]
    resources = [
      "arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:volume/*",
      "arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:network-interface/*",
      "arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:subnet/*",
      "arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:security-group/*",
      "arn:aws:ec2:*::image/*",
    ]
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

  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateLaunchTemplateVersion"
    ]
    resources = ["arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:launch-template/*"]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/creator"
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
    # The Amazon Resource Name (ARN) format for an Elastic IP (EIP) in AWS does not follow the
    # typical resource-specific ARN format used for other resources like instances, volumes, etc.
    # This is because EIPs do not have a direct ARN representation in the same way other EC2 resources do.
    # Instead, permissions for actions involving EIPs, like ec2:DisassociateAddress, are generally specified
    # with wildcards and conditions.
    resources = ["*"]
    # condition {
    #   test     = "StringEquals"
    #   variable = "aws:ResourceTag/creator"
    #   values   = ["deductive-ai"]
    # }
  }

  # Security group management
  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateTags",
      "ec2:DeleteTags",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:DeleteSecurityGroup",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:AuthorizeSecurityGroupEgress"
    ]
    resources = [
      "arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:security-group/*",
      "arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:vpc/vpc-*",
      "arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:subnet/subnet-*",
      "arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:internet-gateway/igw-*",
      "arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:route-table/rtb-*",
      "arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:elastic-ip/eipalloc-*",
      "arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:natgateway/nat-*",
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/creator"
      values   = ["deductive-ai"]
    }
  }

  # Security group management for EKS clusters
  # statement {
  #   effect = "Allow"
  #   actions = [
  #     "ec2:CreateTags",
  #     "ec2:DeleteTags",
  #   ]
  #   resources = [
  #     "arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:security-group/*"
  #   ]
  #   condition {
  #     test     = "StringLike"
  #     variable = "aws:ResourceTag/aws:eks:cluster-name"
  #     # Right now we only have the cluster name for restriction, currently just use *
  #     values   = ["*"]
  #   }
  # }

  # Allow Karpenter to read from DeductiveAI's scaling SQS
  statement {
    effect = "Allow"
    actions = [
      "sqs:createqueue",
      "sqs:getqueueattributes",
    ]
    resources = [
      "arn:aws:sqs:*:${data.aws_caller_identity.current.account_id}:DeductiveKarpenterInterruptionQueue*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/creator"
      values   = ["deductive-ai"]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "sqs:tagqueue",
      "sqs:getqueueattributes",
      "sqs:listqueuetags",
      "sqs:setqueueattributes",
      "sqs:deletequeue",
    ]
    resources = [
      "arn:aws:sqs:*:${data.aws_caller_identity.current.account_id}:DeductiveKarpenterInterruptionQueue*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/creator"
      values   = ["deductive-ai"]
    }
  }

  # Create event rule for Karpenter scaling
  statement {
    effect = "Allow"
    actions = [
      "events:PutTargets",
      "events:DescribeRule",
      "events:ListTagsForResource",
      "events:ListTargetsByRule"
    ]
    resources = [
      "arn:aws:events:*:${data.aws_caller_identity.current.account_id}:rule/*DeductiveKarpenter*"
    ]
  }

  # Tag resource for event
  statement {
    effect = "Allow"
    actions = [
      "events:TagResource",
    ]
    resources = [
      "arn:aws:events:*:${data.aws_caller_identity.current.account_id}:rule/*DeductiveKarpenter*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/creator"
      values   = ["deductive-ai"]
    }
  }

  # Create event rule for Karpenter scaling with tagged resources
  statement {
    effect = "Allow"
    actions = [
      # "events:CreateEventBus",
      "events:DeleteRule",
      "events:RemoveTargets"
    ]
    resources = [
      "arn:aws:events:*:${data.aws_caller_identity.current.account_id}:rule/*DeductiveKarpenter*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/creator"
      values   = ["deductive-ai"]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "events:PutRule",
    ]
    resources = [
      "arn:aws:events:*:${data.aws_caller_identity.current.account_id}:rule/*DeductiveKarpenter*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/creator"
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

  # Enable WAF
  statement {
    effect = "Allow"
    actions = [
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
      "wafv2:CreateWebACL",
      "wafv2:TagResource",
      "wafv2:GetWebACL",
      "wafv2:ListTagsForResource",
      "wafv2:AssociateWebACL",
      "elasticloadbalancing:SetWebACL",
      "wafv2:GetWebACLForResource"
    ]
    resources = ["*"]
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

  # Allow managing role policies for secrets roles
  statement {
    effect = "Allow"
    actions = [
      "iam:PutRolePolicy",
      "iam:GetRolePolicy",
      "iam:DeleteRolePolicy"
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.resource_prefix}*SecretsReaderRole*",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.resource_prefix}*SecretsWriterReaderRole*",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.resource_prefix}*KarpenterControllerRole*",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.resource_prefix}*ALBControllerRole*"
    ]
  }
}

# Define the secrets management policy document
data "aws_iam_policy_document" "secrets_management_policy" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:CreateSecret",
      "secretsmanager:PutSecretValue",
      "secretsmanager:UpdateSecret",
      "secretsmanager:TagResource",
      "secretsmanager:UntagResource",
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:PutResourcePolicy",
      "secretsmanager:DeleteSecret"
    ]
    resources = ["arn:aws:secretsmanager:*:${data.aws_caller_identity.current.account_id}:secret:deductiveai-*"]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/creator"
      values   = ["deductive-ai"]
    }
  }
}

data "aws_iam_policy_document" "ec2_custom_policy_document" {
  statement {
    sid    = "S3Access"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::deductiveai-*/*",
      "arn:aws:s3:::deductiveai-*"
    ]
  }

  # Essential permission for the Application Load Balancer
  statement {
    sid    = "DescribeLoadBalancers"
    effect = "Allow"
    actions = [
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTags",
      "elasticloadbalancing:DescribeTargetGroupAttributes",
      "elasticloadbalancing:DescribeLoadBalancerAttributes",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeListenerAttributes",
      "elasticloadbalancing:DescribeListenerCertificates",
      "elasticloadbalancing:DescribeRules"
    ]
    resources = ["*"]
  }

  statement {
    sid     = "CreateALBSecurityGroup"
    effect  = "Allow"
    actions = ["ec2:CreateSecurityGroup", "ec2:CreateTags"]
    resources = [
      "arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:vpc/vpc*",
      "arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:security-group/*"
    ]
  }

  statement {
    sid    = "CreateALBTargetGroup"
    effect = "Allow"
    actions = [
      "elasticloadbalancing:CreateTargetGroup",
      "elasticloadbalancing:AddTags",
    ]
    resources = [
      "arn:aws:elasticloadbalancing:*:${data.aws_caller_identity.current.account_id}:targetgroup/k8s-default-appui*/*"
    ]
  }

  statement {
    sid    = "CreateAppUIALB"
    effect = "Allow"
    actions = [
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:CreateListener",
    ]
    resources = [
      "arn:aws:elasticloadbalancing:*:${data.aws_caller_identity.current.account_id}:loadbalancer/app/k8s-default-appui*/*"
    ]
  }

  statement {
    sid    = "CreateALBListener"
    effect = "Allow"
    actions = [
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:CreateRule"
    ]
    resources = [
      "arn:aws:elasticloadbalancing:*:${data.aws_caller_identity.current.account_id}:listener/app/k8s-default-appui*/*"
    ]
  }

  statement {
    sid    = "CreateALBListenerRule"
    effect = "Allow"
    actions = [
      "elasticloadbalancing:AddTags"
    ]
    resources = [
      "arn:aws:elasticloadbalancing:*:${data.aws_caller_identity.current.account_id}:listener-rule/app/k8s-default-appui*/*"
    ]
  }
  # End of Application load balancer policies
}