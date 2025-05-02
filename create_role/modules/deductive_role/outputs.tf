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

output "deductive_ai_secrets_arn" {
  description = "The ARN of AWS DeductiveAISecrets"
  value       = aws_secretsmanager_secret.deductive_secrets.arn
}

output "secret_reader_policy_arn" {
  description = "The ARN of the secrets access policy (for EKS pods)"
  value       = aws_iam_policy.secret_reader_policy.arn
}

output "eks_cluster_role_arn" {
  description = "The ARN of the EKS cluster role"
  value       = aws_iam_role.eks_cluster_role.arn
}

output "ec2_role_arn" {
  description = "The ARN of the EC2 instance role"
  value       = aws_iam_role.ec2_role.arn
}

output "secrets_reader_role_arn" {
  description = "The ARN of the secrets reader role"
  value       = aws_iam_role.secrets_reader_role.arn
}

output "secrets_writer_reader_role_arn" {
  description = "The ARN of the secrets writer reader role"
  value       = aws_iam_role.secrets_writer_reader_role.arn
}

output "query_metrics_policy_arn" {
  description = "The ARN of the metrics query policy"
  value       = aws_iam_policy.query_metrics_policy.arn
}

output "s3_clickhouse_policy_arn" {
  description = "The ARN of the S3 ClickHouse policy"
  value       = aws_iam_policy.s3_clickhouse_policy.arn
}
