# AWS Bootstrap Setup for Deductive AI

This Terraform configuration sets up the necessary AWS resources for Deductive AI integration with multi-tenant support.

## Multi-Tenant Setup

This configuration uses **Terraform workspaces** for multi-tenancy. Each tenant gets their own workspace, and the state is automatically stored at `s3://deductive-ai-iac/<tenant>/terraform.tfstate`.

### Initial Setup (One Time)

```bash
# Bootstrap S3 bucket and initialize Terraform
./bootstrap-s3.sh -p <your_aws_profile>
```

This will:
- Create the S3 bucket `deductive-ai-iac` if it doesn't exist
- Enable versioning and encryption on the bucket
- Initialize Terraform backend

### Per-Tenant Setup

For each tenant, create a workspace:

```bash
# Create and switch to tenant workspace
terraform workspace new <tenant>

# Apply configuration
terraform apply -var="external_id=<external_id_from_deductive_ai>" -var="tenant=<tenant>" -var="aws_profile=<your_aws_profile>"
```

### Switching Between Tenants

```bash
# List available workspaces
terraform workspace list

# Switch to a specific tenant
terraform workspace select <tenant>

# Run terraform commands for that tenant
terraform plan -var="external_id=<external_id>" -var="tenant=<tenant>" -var="aws_profile=<profile>"
terraform apply -var="external_id=<external_id>" -var="tenant=<tenant>" -var="aws_profile=<profile>"
```

### State Storage

- **Default workspace**: `s3://deductive-ai-iac/terraform.tfstate` (not used)
- **Tenant workspaces**: `s3://deductive-ai-iac/<tenant>/terraform.tfstate`

### Example Usage

```bash
# One-time setup
terraform init

# Set up for "acme-corp" tenant
terraform workspace new acme-corp
terraform apply -var="external_id=abc123def456" -var="tenant=acme-corp" -var="aws_profile=my-profile"

# Later, work with "acme-corp" tenant
terraform workspace select acme-corp
terraform plan -var="external_id=abc123def456" -var="tenant=acme-corp" -var="aws_profile=my-profile"

# Set up for "beta-company" tenant
terraform workspace new beta-company
terraform apply -var="external_id=xyz789uvw" -var="tenant=beta-company" -var="aws_profile=my-profile"
```

### Handling Existing IAM Roles

If you encounter an error like "Role with name DeductiveAssumeRole already exists", use the import script:

```bash
# Import existing role before applying
./import-existing-roles.sh <tenant> <aws_profile>

# Example
./import-existing-roles.sh foursquare vendor-user

# Then proceed with terraform apply
terraform apply -var="external_id=<external_id>" -var="tenant=<tenant>" -var="aws_profile=<aws_profile>"
```

**Note**: This happens when testing multiple tenants in the same AWS account. The `DeductiveAssumeRole` is shared across tenants but each tenant has separate Terraform state.

## Variables

You'll need:
- External ID (provided by Deductive AI)

Optional parameters:
- AWS region (e.g., `-var="region=us-east-1"`)
- AWS profile (e.g., `-var="aws_profile=my-profile"`)


