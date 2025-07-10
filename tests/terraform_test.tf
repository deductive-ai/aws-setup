terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}

run "basic_validation" {
  module {
    source = "../"
  }

  variables {
    tenant                   = "test-tenant"
    external_id              = "test-external-id"
    deductive_aws_account_id = "123456789012"
  }
} 