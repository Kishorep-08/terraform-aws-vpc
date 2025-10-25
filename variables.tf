variable "vpc_cidr_block" {
    type = string
    description = "This CIDR block is for vpc"
}

variable "project_name" {
    type = string
}

variable "environment" {
    type = string
}

variable "public_subnet_cidrs" {
    type = list
}

variable "private_subnet_cidrs" {
    type = list
}

variable "database_subnet_cidrs" {
    type = list
}

variable "is_peering_required" {
    type = bool
    default = true
}