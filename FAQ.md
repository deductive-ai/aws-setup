# Terraform Backend Management

This repository supports remote state management using S3 with automated safety features.

## Quick Start

### One-Time Setup
```bash
# Install git hooks and validate Go installation
make setup-git-hooks
```

### Daily Workflow
```bash
# Standard usage (local backend - default)
make use-local-backend
terraform plan -var="tenant=<tenant>" -var="region=<region>" -var="external_id=<external_id>"
terraform apply -var="tenant=<tenant>" -var="region=<region>" -var="external_id=<external_id>"
git commit -m "your changes"  # Auto-enforces local backend

# Multi-tenant AWS (S3 backend)
make use-s3-backend
terraform plan -var="tenant=<tenant>" -var="region=<region>" -var="external_id=<external_id>"
terraform apply -var="tenant=<tenant>" -var="region=<region>" -var="external_id=<external_id>"
make use-local-backend  # Switch back before committing
```

## Backend Types

### Local Backend (Default)

- **Usage**: Standard customer deployments
- **State Storage**: `terraform.tfstate` (local file)
- **Command**: `make use-local-backend`
- **Safety**: Required for all commits (enforced by pre-commit hook)

### S3 Backend (Multi-tenant)

- **Usage**: Deductive AWS multi-tenant environments
- **State Storage**: `s3://deductive-ai-iac/terraform.tfstate`
- **Command**: `make use-s3-backend`
- **Safety**: Automatically switched to local before commits

## Features

### Automated Git Hooks
The pre-commit hook automatically:
- **Detects S3 backend** in commits and switches to local
- **Runs validation pipeline** (terraform fmt, validate, tflint, tfsec, checkov)
- **Prevents broken commits** with clear error messages
- **Provides usage instructions** when S3 backend detected

### Available Commands
```bash
# Backend Management
make use-local-backend    # Switch to local backend
make use-s3-backend       # Switch to S3 backend

# Setup & Validation
make setup-git-hooks      # Install git hooks (one-time)
make validate            # Run validation pipeline
make format              # Format Terraform files

# Tool Installation
make install-tools       # Install tflint, tfsec, checkov
```

## Authentication

### AWS Credentials

This repository uses **environment variables** for AWS authentication:

```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_SESSION_TOKEN="your-session-token"  # If using temporary credentials
```

**Note**: AWS profiles are no longer used - environment variables provide better CI/CD integration.

## Troubleshooting

### Role Already Exists Error

If you see `Role with name <name> already exists`, import it:

```bash
TENANT=<tenant>
AWS_REGION=<region>

terraform import -var="tenant=$TENANT" -var="region=$AWS_REGION" -var="external_id=<external_id>" module.bootstrap.aws_iam_role.deductive_role DeductiveAssumeRole-${TENANT}
```

### Pre-commit Hook Issues

If the pre-commit hook fails:

```bash
# Check Go installation
go version  # Should be 1.21+

# Reinstall hooks
make setup-git-hooks

# Run validation manually
make validate
```

### Backend Switch Issues

If backend switching fails:

```bash
# Check providers.tf syntax
terraform validate

# Force clean initialization
rm -rf .terraform
make use-local-backend
terraform init
```

### Permission Errors

If AWS operations fail:

```bash
# Verify credentials
aws sts get-caller-identity

# Check environment variables
echo $AWS_ACCESS_KEY_ID
echo $AWS_SECRET_ACCESS_KEY
```

## Development Requirements

### Setup environments

```bash
make setup-env
```

### Required Tools
- **Go 1.21+** (for hclwrite backend management)
- **Terraform** (infrastructure management)
- **tflint** (Terraform linting)
- **tfsec** (security scanning)
- **checkov** (compliance checking)

### Standard Workflow

1. **Setup**: `make setup-git-hooks` (one-time)
2. **Standard usage**: Use `make use-local-backend` (default)
3. **Validation**: `make validate` before commits
4. **Multi-tenant**: `make use-s3-backend` for Deductive AWS operations
5. **Commit**: Always switch back with `make use-local-backend`

## FAQ

### Q: When should I use S3 backend?

**A**: Only for Deductive AWS multi-tenant environments. Standard customer deployments should use local backend (default).

### Q: What if I don't have Go installed?

**A**: Go 1.24.5 is required for the hclwrite-based backend management. Install with `brew install go` on macOS or from [golang.org](https://golang.org/dl/).

### Q: How do I update Terraform version?

**A**: Refer to [HashiCorp Terraform installation guide](https://developer.hashicorp.com/terraform/install) for the latest version.
