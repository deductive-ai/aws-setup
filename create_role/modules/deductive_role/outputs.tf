/*
 Copyright (c) 2023, Deductive AI, Inc. All rights reserved.

 This software is the confidential and proprietary information of
 Deductive AI, Inc. You shall not disclose such confidential
 information and shall use it only in accordance with the terms of
 the license agreement you entered into with Deductive AI, Inc.
*/
output "deductive_role_arn" {
  description = "The ARN of the Deductive role - share this with Deductive"
  value       = aws_iam_role.deductive_role.arn
}

output "eks_cluster_role_arn" {
  description = "The ARN of the EKS cluster role"
  value       = aws_iam_role.eks_cluster_role.arn
}

output "ec2_role_arn" {
  description = "The ARN of the EC2 instance role"
  value       = aws_iam_role.ec2_role.arn
}
