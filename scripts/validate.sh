#!/usr/bin/env bash
set -e

source .venv/bin/activate

echo "Running Terraform Validation..."

# Check required tools
for tool in terraform tflint tfsec checkov; do
    command -v $tool >/dev/null || { echo "ERROR: $tool not found"; exit 1; }
done

# Run validation steps
terraform fmt -check -recursive
terraform init
terraform validate
tflint --init && tflint --minimum-failure-severity=error
tfsec . --soft-fail
checkov -d . --framework terraform --quiet --soft-fail || true
terraform test

echo "All validation checks passed!"
