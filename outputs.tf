output "share_with_deductive" {
  description = "The ARNs of the resources to share with Deductive AI"
  value = {
    "aws_region"           = var.region
    "deductive_role_arn"   = module.bootstrap.deductive_role_arn
    "eks_cluster_role_arn" = module.bootstrap.eks_cluster_role_arn
    "ec2_role_arn"         = module.bootstrap.ec2_role_arn
  }
} 