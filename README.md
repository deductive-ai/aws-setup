Following steps are expected:

1. Customer will have to apply the terraform script to create the policy using
   customer_create_role.tf in the aws account where deductive will run:
```
terraform apply -var="region=<aws_region>" -var="aws_profile=<aws_profile>"
```
