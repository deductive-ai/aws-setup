# Bootstrap Module

This module provides the core infrastructure required for Deductive AI to operate in your AWS account. It creates the necessary IAM roles with appropriate permissions for secure cross-account access.

## Resources Created

- **DeductiveAssumeRole**: Main role that Deductive AI will assume to manage resources
- **EKS Cluster Role**: Role for EKS cluster with permissions to manage EKS services
- **EC2 Role**: Role for EC2 instances that run as worker nodes in the EKS cluster

## Usage

```hcl
module "bootstrap" {
  source = "git::https://github.com/deductive-ai/aws-setup.git//modules/bootstrap?ref=v1.0.0"

  role_info = {
    resource_prefix         = "Deductive"
    cluster_name            = "customer-cluster-name"
    external_id             = "<external_id_from_deductive>"              # Optional but recommended for security
    deductive_aws_account_id = "deductive-aws-account-number" # Will be provided by Deductive AI
  }

  # Optional additional tags for resources
  additional_tags = {
    Environment = "Production"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| role_info | Object containing role configuration including required cluster_name field | object | See below | yes |
| additional_tags | Additional tags to apply to all resources | map(string) | {} | no |

### role_info Object Structure

```hcl
role_info = {
  resource_prefix         = string
  cluster_name            = string
  external_id             = optional(string, null)
  deductive_aws_account_id = optional(string, null)
}
```

## Outputs

| Name | Description |
|------|-------------|
| deductive_role_arn | The ARN of the Deductive role |
| eks_cluster_role_arn | The ARN of the EKS cluster role |
| ec2_role_arn | The ARN of the EC2 role |
