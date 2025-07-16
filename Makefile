.PHONY: validate format use-local-backend use-s3-backend setup-git-hooks install-tools clean

validate: ## Run validation pipeline
	./scripts/validate.sh

format: ## Format Terraform files
	terraform fmt -recursive

use-local-backend:
	./scripts/backend-toggle.sh local

use-s3-backend:
	./scripts/backend-toggle.sh s3

setup-git-hooks:
	./scripts/setup-git-hooks.sh

install-tools: ## Install required tools (macOS)
	brew install tflint tfsec
	pipx install checkov

clean: ## Clean up Terraform files
	rm -rf .terraform terraform.tfstate* tfplan 