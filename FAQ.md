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

3. Create new workspace (for multi-tenant environments)

```bash
terraform workspace new <tenant>
```

4. Plan the change

```bash
terraform plan -var="tenant=<tenant>" -var="region=<region>" -var="aws_profile=<profile>"
```

5. Apply if the change looks good

```bash
terraform apply -var="tenant=<tenant>" -var="region=<region>" -var="aws_profile=<profile>"
```

if you see `Role with name <name> already exists`, import it:

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
