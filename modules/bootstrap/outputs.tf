/*
 Copyright (c) 2023, Deductive AI, Inc. All rights reserved.

 This software is the confidential and proprietary information of
 Deductive AI, Inc. You shall not disclose such confidential
 information and shall use it only in accordance with the terms of
 the license agreement you entered into with Deductive AI, Inc.
*/

# Output the ARNs of the created roles

output "deductive_role_arn" {
  description = "The ARN of the Deductive role that can be assumed to manage AWS resources"
  value       = aws_iam_role.deductive_role.arn
}

