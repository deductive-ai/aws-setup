# Deductive AI AWS Integration

This repository contains Terraform configurations to set up AWS integration for Deductive AI.

## Prerequisites

- Ubuntu/Debian/Fedora or macOS
- External ID provided by Deductive AI
- Tenant identifier for your organization

## Quick Start

1. **Clone this repository**

   ```bash
   git clone https://github.com/deductive-ai/aws-setup.git
   cd aws-setup
   ```
** One time setup for the environment setup for this repo:
```
make setup-env
```

2. **Initialize and apply the configuration**

   ```bash
   export AWS_PROFILE=<your-aws-profile> TENANT=<tenant> REGION=<region> EXTERNAL_ID=<external_id_from_deductive>
   terraform init
   terraform plan -var="tenant=$TENANT" -var="region=$REGION" -var="external_id=$EXTERNAL_ID" -var="aws_profile=$AWS_PROFILE"
   ```

   > **Note:** Review the plan output above. If everything looks correct, proceed with the apply command.

   ```bash
   terraform apply -var="tenant=$TENANT" -var="region=$REGION" -var="external_id=$EXTERNAL_ID" -var="aws_profile=$AWS_PROFILE"
   ```

3. **Share the output with Deductive AI**

   After successful deployment, you'll receive output similar to:
   ```bash
   Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

   Outputs:

   share_with_deductive = {
     "aws_region" = "us-west-1"
     "deductive_role_arn" = "arn:aws:iam::123456789012:role/DeductiveAssumeRole-<tenant>"
   }
   ```

   Share the `deductive_role_arn` value with your Deductive AI representative.
