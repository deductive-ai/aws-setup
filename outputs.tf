output "share_with_deductive" {
  description = "Complete information to share with Deductive AI for onboarding"
  value = {
    # Main role ARN that Deductive AI will assume (ONLY REQUIRED VALUE)
    "deductive_role_arn"   = module.bootstrap.deductive_role_arn
    
    # Deployment configuration
    "aws_region"           = var.region
    "aws_account_id"       = data.aws_caller_identity.current.account_id
    "tenant"               = var.tenant
    "environment"          = var.environment
    
    # Customer access information
    "customer_subdomain"   = var.customer_subdomain
    "app_ui_url"           = var.customer_subdomain != null ? "https://${var.customer_subdomain}.deductive.ai" : "https://${var.tenant}.deductive.ai"
  }
}

# Separate output for quick role ARN access
output "deductive_role_arn" {
  description = "The main IAM role ARN that Deductive AI assumes (ONLY role needed - we create others dynamically)"
  value       = module.bootstrap.deductive_role_arn
}

# Customer-facing information
output "your_app_ui_url" {
  description = "Your app-UI will be accessible at this URL once deployed"
  value       = var.customer_subdomain != null ? "https://${var.customer_subdomain}.deductive.ai" : "https://${var.tenant}.deductive.ai"
} 