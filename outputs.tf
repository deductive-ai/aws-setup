
output "share_with_deductive" {
  description = "The ARNs of the resources to share with Deductive AI"
  value = {
    "aws_region"           = var.region
    "deductive_role_arn"   = module.bootstrap.deductive_role_arn
    "aws_setup_version"       = module.bootstrap.git_branch
  }
} 