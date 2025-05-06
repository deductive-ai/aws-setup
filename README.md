# Deductive AI AWS Integration

This Terraform configuration creates the necessary AWS resources for integrating Deductive AI with your AWS account.

## Overview

This configuration creates:

1. An IAM role that Deductive AI can assume to manage resources in your AWS account
2. A Secrets Manager secret for storing configuration data
3. Necessary policies with least-privilege permissions

## Security Considerations

- All resources created by Deductive AI are tagged with `creator = "deductive-ai"`
- IAM permissions are scoped to only the resources that Deductive AI needs to manage
- The role can only be assumed by the Deductive AI AWS account

## Usage

### Prerequisites

- Terraform version >= 1.11.4 installed
- AWS CLI configured with appropriate credentials

### Deployment

1. Clone this repository
2. Navigate to the repository directory
3. Run the following commands:

```bash
terraform init
terraform plan -var="region=<aws_region>" -var="aws_profile=<aws_profile>" -var="deductive_aws_account_id=<deductive_aws_account_id>" -var "external_id=<external_id_from_deductive_ai>"
terraform apply -var="region=<aws_region>" -var="aws_profile=<aws_profile>" -var="deductive_aws_account_id=<deductive_aws_account_id>" -var "external_id=<external_id_from_deductive_ai>"
```
