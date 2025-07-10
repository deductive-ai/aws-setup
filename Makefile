.PHONY: validate format install-tools clean

validate: ## Run validation pipeline
	./scripts/validate.sh

format: ## Format Terraform files
	terraform fmt -recursive

install-tools: ## Install required tools (macOS)
	brew install tflint tfsec
	pipx install checkov

clean: ## Clean up Terraform files
	rm -rf .terraform terraform.tfstate* tfplan 