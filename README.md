# Deductive AI AWS Integration

This Terraform configuration creates the necessary AWS IAM role for the Deductive AI platform to operate within your AWS account.

## Prerequisites

- An AWS account with permissions to create IAM roles.
- Terraform v1.0 or later installed.
- AWS CLI installed and configured with your credentials.

## Setup Instructions

1.  **Clone Repository**
    ```bash
    git clone https://github.com/deductive-ai/aws-onboarding.git
    cd aws-onboarding
    ```

2.  **Configure Variables**
    Copy the example variables file.
    ```bash
    cp terraform.tfvars.example terraform.tfvars
    ```
    Edit `terraform.tfvars` with the values provided by your Deductive AI representative.

3.  **Apply Terraform Configuration**
    Initialize Terraform and apply the configuration.
    ```bash
    terraform init
    terraform apply
    ```

4.  **Provide Role ARN to Deductive AI**
    After the apply completes, the required IAM Role ARN will be displayed as an output. Provide this ARN to your Deductive AI representative to complete the integration.
    ```bash
    terraform output deductive_role_arn
    ```

## Resources Created

This configuration creates a single cross-account IAM role. This role is scoped with a unique external ID and can only be assumed by Deductive AI's specified AWS account. The permissions granted are limited to those necessary for the operation of the Deductive AI service, which includes managing EKS clusters, EC2 instances, and related networking resources.

## Support

If you encounter any issues during this process, please contact your Deductive AI support representative or email support@deductive.ai.

## Cleanup

To remove the resources created by this configuration, run the following command:
```bash
terraform destroy
``` 