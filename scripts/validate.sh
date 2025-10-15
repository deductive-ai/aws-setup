#!/usr/bin/env bash
set -e

if [ -f .venv/bin/activate ]; then
    # This is just to ensure checkov for non-github action environments
    # The reason is to speed up the github action in general
    source .venv/bin/activate
fi

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
