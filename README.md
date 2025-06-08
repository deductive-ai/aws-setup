# Deductive AI AWS Integration

Set up AWS integration for Deductive AI in three simple steps:

1. Clone this repository
2. Run:

```bash
terraform init
terraform plan -var="tenant=<tenant>" -var="external_id=<external_id_from_deductive_ai>"
terraform apply -var="tenant=<tenant>" -var="external_id=<external_id_from_deductive_ai>"
```

3. Share the role ARNs from the output with Deductive AI

Example output:

```bash
Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

share_with_deductive = {
  "deductive_role_arn"   = "arn:aws:iam::123456789012:role/DeductiveAssumeRole"
  "eks_cluster_role_arn" = "arn:aws:iam::123456789012:role/DeductiveEKSClusterRole"
  "ec2_role_arn"         = "arn:aws:iam::123456789012:role/DeductiveEC2Role-tenant"
}
```

You'll need:

- External ID (provided by Deductive AI)

Optional parameters:

- AWS region (e.g., `-var="region=us-west-1"`)
- AWS profile (e.g., `-var="aws_profile=my-profile"`)
