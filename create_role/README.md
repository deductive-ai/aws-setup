# Deductive AI AWS Bootstrap Roles

This Terraform module creates IAM roles necessary for Deductive AI to operate in your AWS account.

## What this module does

The bootstrap_roles module creates the following IAM roles:

1. **DeductiveAssumeRole** - The main role that DeductiveAI assumes to manage resources
   - Permissions: EC2, EKS, IAM, ACM, S3, Secrets Manager, and other AWS services
   - Purpose: Allows DeductiveAI to provision and manage the infrastructure

2. **EKSClusterRole** - Role for EKS cluster with permissions to manage EKS services
   - Permissions: AmazonEKSClusterPolicy, AmazonEKSServicePolicy
   - Purpose: Allows the EKS control plane to manage AWS resources on behalf of the cluster

3. **EC2Role** - Role for EC2 instances that run as worker nodes in the EKS cluster
   - Permissions: AmazonEKSWorkerNodePolicy, AmazonEKS_CNI_Policy, AmazonEC2ContainerRegistryReadOnly, AmazonEBSCSIDriverPolicy
   - Purpose: Allows worker nodes to join the cluster and access required AWS services

## Usage

```hcl
provider "aws" {
  region  = "us-east-2"  # Specify your preferred region
  profile = "default"    # Specify your AWS profile if not using default
}

module "bootstrap_roles" {
  source = "github.com/deductive-ai/deductive-aws-setup//create_role/modules/deductive_role?ref=main"

  # Optional: customize the resource prefix (default is "Deductive")
  resource_prefix = "Deductive"
  
  # Optional: Deductive AWS account ID (defaults will use if not provided)
  deductive_aws_account_id = "ACCOUNT_ID_PROVIDED_BY_DEDUCTIVE"  
  
  # Will be provided by Deductive
  external_id = "EXTERNAL_ID_PROVIDED_BY_DEDUCTIVE" 

  # Optional: Add additional tags to all created resources
  additional_tags = {
    environment = "production"
    project     = "deductive-integration"
    owner       = "your-team"
  }
}

# Output the ARNs - these need to be shared with Deductive
output "deductive_role_arn" {
  description = "The ARN of the Deductive role"
  value       = module.bootstrap_roles.deductive_role_arn
}

output "eks_cluster_role_arn" {
  description = "The ARN of the EKS cluster role"
  value       = module.bootstrap_roles.eks_cluster_role_arn
}

output "ec2_role_arn" {
  description = "The ARN of the EC2 instance role"
  value       = module.bootstrap_roles.ec2_role_arn
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| aws | >= 3.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| resource_prefix | Prefix to add to resource names for uniqueness | `string` | `"Deductive"` | no |
| deductive_aws_account_id | Deductive AI's AWS account ID for cross-account permissions | `string` | `********` | no |
| external_id | External ID for secure cross-account role assumption | `string` | `null` | no |
| additional_tags | Additional tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| deductive_role_arn | The ARN of the Deductive role that can be assumed to manage AWS resources |
| eks_cluster_role_arn | The ARN of the EKS cluster role that allows EKS control plane to manage resources |
| ec2_role_arn | The ARN of the EC2 instance role for worker nodes in the EKS cluster |

## Security Notes

- Uses external ID to prevent confused deputy problem
- Has explicit deny statements for admin access
- Implements least privilege principle with specific resource restrictions
- Tags all resources with creator="deductive-ai" for tracking and management 