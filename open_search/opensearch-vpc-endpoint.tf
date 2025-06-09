/*
 Copyright (c) 2023, Deductive AI, Inc. All rights reserved.

 This software is the confidential and proprietary information of
 Deductive AI, Inc. You shall not disclose such confidential
 information and shall use it only in accordance with the terms of
 the license agreement you entered into with Deductive AI, Inc.
*/

/*
 This is an example configuration for setting up a VPC endpoint for OpenSearch.
 You can use this as a reference if you need to set up PrivateLink access.
 The main file you need is opensearch-privatelink-role.tf.
*/

#################################################
# Variables
#################################################
variable "vpc_id" {
  description = "VPC ID where the VPC endpoint will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs where the VPC endpoint will be created"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs to attach to the VPC endpoint"
  type        = list(string)
}

variable "opensearch_domain_name" {
  description = "Name of your OpenSearch domain"
  type        = string
}

variable "opensearch_aws_region" {
  description = "AWS region where your OpenSearch domain exists"
  type        = string
}

#################################################
# Resources
#################################################
# Create VPC Endpoint for OpenSearch
resource "aws_vpc_endpoint" "opensearch" {
  vpc_id             = var.vpc_id
  service_name       = "com.amazonaws.${var.opensearch_aws_region}.es"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = var.subnet_ids
  security_group_ids = var.security_group_ids

  private_dns_enabled = true

  tags = {
    Name = "DeductiveAIOpenSearchEndpoint"
  }
}

# Create Route53 private hosted zone for OpenSearch domain
resource "aws_route53_zone" "opensearch" {
  name = "${var.opensearch_domain_name}.${var.opensearch_aws_region}.es.amazonaws.com"
  vpc {
    vpc_id = var.vpc_id
  }

  tags = {
    Name = "DeductiveAIOpenSearchZone"
  }
}

#################################################
# Outputs
#################################################
output "vpc_endpoint_id" {
  description = "ID of the created VPC endpoint"
  value       = aws_vpc_endpoint.opensearch.id
}

output "vpc_endpoint_dns_entries" {
  description = "DNS entries for the VPC endpoint"
  value       = aws_vpc_endpoint.opensearch.dns_entry
}
