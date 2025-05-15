# Deductive AI AWS Integration

This Terraform module repository creates the necessary AWS resources for integrating Deductive AI with your AWS account.

## Overview

The repository is organized into Terraform modules that can be easily referenced:

```
modules/
  bootstrap/  # Core IAM roles and policies for Deductive AI integration
```

## Module Usage

### As a Module Reference

You can reference the modules directly in your own Terraform configurations:

```hcl
module "deductive_bootstrap" {
  source = "git::https://github.com/deductive-ai/aws-setup.git//modules/bootstrap?ref=v1.0.2"
  
  role_info = {
    resource_prefix         = "Deductive"
    external_id             = "your-external-id"              # Provided by Deductive AI
    deductive_aws_account_id = "deductive-aws-account-number" # Provided by Deductive AI
  }
}
```

### Standalone Usage

You can also use the root configuration directly:

1. Clone this repository
2. Navigate to the repository directory
3. Run the following commands:

```bash
terraform init
terraform plan -var="region=<aws_region>" -var="aws_profile=<aws_profile>" -var="external_id=<external_id_from_deductive_ai>"
terraform apply -var="region=<aws_region>" -var="aws_profile=<aws_profile>" -var="external_id=<external_id_from_deductive_ai>"
```

## Security Considerations

- All resources created by Deductive AI are tagged with `creator = "deductive-ai"`
- IAM permissions are scoped to only the resources that Deductive AI needs to manage
- The role can only be assumed by the Deductive AI AWS account
- External ID is used to prevent confused deputy problems
