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
  "deductive_role_arn"   = "arn:aws:iam::123456789012:role/DeductiveAIAssumeRole"
  "eks_cluster_role_arn" = "arn:aws:iam::123456789012:role/DeductiveAIEKSClusterRole"
  "ec2_role_arn"         = "arn:aws:iam::123456789012:role/DeductiveAIEC2Role-tenant"
}
```

You'll need:

- External ID (provided by Deductive AI)

Optional parameters:

- AWS region (e.g., `-var="region=us-west-1"`)
- AWS profile (e.g., `-var="aws_profile=my-profile"`)


# (Optional) Sync state to S3 bucket
Optionally, you can save terraform state to s3 bucket.
1. explicitly defined the backend in providers.tf, otherwise you will see terraform raised warning about `-backend-config was used without a "backend" block in the configuration.`
```hcl
terraform {
  backend "s3" {
    bucket  = <bucket>
    key     = "terraform.tfstate"
    region  = <region>
    encrypt = true
  }
}
```
2. Migrate the state from local to s3 (note you may need to switch workspace (via tenant) if you are under multitenant environment `terraform workspace select <tenant>`), then
```bash
terraform init
```
3. Create new workspace
```bash
terraform workspace new <tenant>
4. Plan the change
```bash
 terraform plan -var="tenant=<tenant>" -var="region=<region>" -var="aws_profile=<profile>"
```
5. Apply if things looks sanity
```bash
 terraform apply -var="tenant=<tenant>" -var="region=<region>" -var="aws_profile=<profile>"
```