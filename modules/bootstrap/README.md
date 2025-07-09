# AWS Bootstrap Module

## Purpose

This Terraform module is responsible for creating the AWS IAM resources required for the Deductive AI platform to operate. It creates a single, cross-account IAM role that the Deductive AI control plane assumes to manage resources within the customer's AWS account.

## Resources

- **`aws_iam_role`**: The primary cross-account role for the Deductive AI service.
- **`aws_iam_role_policy`**: An inline policy attached to the role, granting necessary permissions for service operation.
- **`aws_iam_role_policy_attachment`**: Attaches required AWS managed policies (e.g., for the EBS CSI driver).

## Usage

This module is intended for internal use by the root Terraform configuration and is not designed to be used directly. It receives all necessary inputs, such as the tenant identifier and external ID, from the root module. 