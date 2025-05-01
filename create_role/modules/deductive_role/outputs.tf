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
