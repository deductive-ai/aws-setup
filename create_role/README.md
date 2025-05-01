
/*
 Copyright (c) 2023, Deductive AI, Inc. All rights reserved.

 This software is the confidential and proprietary information of
 Deductive AI, Inc. You shall not disclose such confidential
 information and shall use it only in accordance with the terms of
 the license agreement you entered into with Deductive AI, Inc.
*/

## 3. README.md

```language=markdown:README.md
# Deductive AI AWS Integration

This Terraform configuration creates the necessary AWS resources for integrating Deductive AI with your AWS account.

## Overview

This configuration creates:

1. An IAM role that Deductive AI can assume to manage resources in your AWS account
2. A Secrets Manager secret for storing configuration data
3. Necessary policies with least-privilege permissions

## Security Considerations

- All resources created by Deductive AI are tagged with `creator = "deductive-ai"`
- IAM permissions are scoped to only the resources that Deductive AI needs to manage
- The role can only be assumed by the Deductive AI AWS account

## Usage

### Prerequisites

- Terraform v0.14+ installed
- AWS CLI configured with appropriate credentials

### Deployment

1. Clone this repository
2. Navigate to the repository directory
3. Run the following commands:

```bash
terraform init
terraform plan -var="region=<aws_region>" -var="aws_profile=<aws_profile>"
terraform apply -var="region=<aws_region>" -var="aws_profile=<aws_profile>"
```

