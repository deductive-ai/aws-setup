Following steps are expected:

1. Customer will have to apply the terraform script to create the policy using
   customer_create_role.tf, such as:
```
terraform apply -var="region=us-east-2" -var="aws_profile=customer" -var="deductive_aws_account_id=590183993904"
```
2. Deductive will have to give the permission to ctrl-plane-user to Assume role in
   customers account using customer_assume_role.tf:
```
terraform apply -var="region=us-east-2" -var="aws_profile=vendor" -var="customer_aws_account_id=590183930955"
```