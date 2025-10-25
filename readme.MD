# AWS VPC terraform module

This module creates VPC and other following network components on AWS:

* VPC
* Internet Gateway (IGW)
* 2 Public subnets in us-east-1a and us-east-1b AZs respectively
* 2 Private subnets in us-east-1a and us-east-1b AZs respectively
* 2 Database subnets in us-east-1a and us-east-1b AZs respectively
* 1 Route table for public subnet
* 1 Route table for private subnet
* 1 Route table for database subnet
* Elastic IP for NAT gateway
* NAT gateway in public subnet us-east-1a AZ
* IGW route added in public subnet route table
* Egress route through NAT for private subnet
* Egress route through NAT for database subnet
* Route table association for public subnet
* Route table association for private subnet
* Route table association for database subnet
* VPC peering connection between roboshop and default VPCs
* Public route table to default VPC route
* Default VPC main route table to created VPC route

## Inputs

* vpc_cidr - (Required) User must supply cidr range
* project_name - (Required) User must supply project name to bring uniqueness to the resource names
* environment - (Required) User must supply environment to bring uniqueness to the resource names
* public_subnet_cidrs - (Required) User must provide 2 cidr ranges for two public subnets
* private_subnet_cidrs - (Required) User must provide 2 cidr ranges for two public subnets
* database_subnet_cidrs - (Required) User must provide 2 cidr ranges for two public subnets

## Outputs

* vpc_id - VPC ID will be given as output after the complete execution
* public_subnet_ids - IDs of two public subnets
* private_subnet_ids - IDs of two private subnets
* database_subnet_ids - IDs of two database subnets

