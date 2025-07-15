# Backend Configuration

This repository supports both local and S3 backends with a safe-by-default approach.

## Local Backend (Default)

By default, Terraform uses local backend:

```bash
terraform init
terraform plan
terraform apply
```

State is stored locally in `terraform.tfstate`.

## S3 Backend (for multi-tenant environment)

To use S3 backend:

```bash
terraform init -backend-config=backend-s3.conf
terraform plan
terraform apply
```

State is stored in S3 bucket: `s3://deductive-ai-iac/<tenant>/terraform.tfstate`

## Backend Configuration Files

The repository includes:

- `backend-local.conf` - Local backend configuration (default)
- `backend-s3.conf` - S3 backend configuration

## Multi-tenant Workspaces

For multi-tenant environments, switch workspace before operations:

```bash
# Create new workspace
terraform workspace new <tenant>

# Or select existing workspace
terraform workspace select <tenant>

# Then run normal commands
terraform plan -var="tenant=<tenant>" -var="region=<region>" -var="aws_profile=<profile>"
terraform apply -var="tenant=<tenant>" -var="region=<region>" -var="aws_profile=<profile>"
```

## Troubleshooting

If you see `Role with name <name> already exists`, import it:

```bash
TENANT=<tenant>
AWS_PROFILE=<profile>
AWS_REGION=<region>

terraform import -var="tenant=$TENANT" -var="aws_profile=$AWS_PROFILE" -var="region=$AWS_REGION" module.bootstrap.aws_iam_role.deductive_role DeductiveAssumeRole-${TENANT}
```

## Common FAQ

If you see terraform version issue, please refer to [terraform](https://developer.hashicorp.com/terraform/install)
for installing the latest version.

## Development

If you want to submit the change, don't forget to install `tflint`, `tfsec`, and `checkov`.
