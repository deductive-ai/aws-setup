#!/bin/bash

if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <tenant> <aws_profile>"
    echo "Example: $0 tenant aws-profile"
    exit 1
fi

TENANT="$1"
AWS_PROFILE="$2"

terraform import \
  -var="tenant=${TENANT}" \
  -var="aws_profile=${AWS_PROFILE}" \
  module.bootstrap.aws_iam_role.deductive_role \
  DeductiveAssumeRole