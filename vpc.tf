# VPC
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = merge (
    local.common_tags,
    {
        Name = "${local.common_name}-vpc"
    }
  )
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
 vpc_id = aws_vpc.main.id
 tags = merge (
    local.common_tags,
    {
        Name = "${local.common_name}-igw"
    }
  )
}

# Public subnet
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidrs[count.index]
  availability_zone = local.az_names[count.index]
  map_public_ip_on_launch = true
  tags = merge (
    local.common_tags,
    {
        Name = "${local.common_name}-public-${local.az_names[count.index]}"   # roboshop-dev-public-us-east-1a
    }  
  )
 
}

# Private subnet
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidrs[count.index]
  availability_zone = local.az_names[count.index]
  tags = merge (
    local.common_tags,
    {
        Name = "${local.common_name}-private-${local.az_names[count.index]}"   # roboshop-dev-private-us-east-1a
    }  
  )
 
}

# Database subnet
resource "aws_subnet" "database" {
  count = length(var.database_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_subnet_cidrs[count.index]
  availability_zone = local.az_names[count.index]
  map_public_ip_on_launch = true
  tags = merge (
    local.common_tags,
    {
        Name = "${local.common_name}-database-${local.az_names[count.index]}"   # roboshop-dev-database-us-east-1a
    }  
  )
 
}

# Route table for public subnet
resource "aws_route_table" "route_table_public" {
  vpc_id = aws_vpc.main.id
  tags = merge (
    local.common_tags,
    {
        Name = "${local.common_name}-public"
    }
  )
}  

# Route table for private subnet
resource "aws_route_table" "route_table_private" {
  vpc_id = aws_vpc.main.id
  tags = merge (
    local.common_tags,
    {
        Name = "${local.common_name}-private"
    }
  )
}    

# Route table for database subnet
resource "aws_route_table" "route_table_database" {
  vpc_id = aws_vpc.main.id
  tags = merge (
    local.common_tags,
    {
        Name = "${local.common_name}-database"
    }
  )
} 

# Route for public subnet
resource "aws_route" "public_route" {
  route_table_id            = aws_route_table.route_table_public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main.id
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain   = "vpc"
  tags = merge (
    local.common_tags,
    {
        Name = "${local.common_name}-nat"
    }
  )
}

# NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge (
    local.common_tags,
    {
        Name = "${local.common_name}"
    }
  )
  depends_on = [aws_internet_gateway.main]
}

# egress route through NAT for private subnet
resource "aws_route" "private_route" {
  route_table_id            = aws_route_table.route_table_private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat_gateway.id
}

# egress route through NAT for database subnet
resource "aws_route" "database_route" {
  route_table_id            = aws_route_table.route_table_database.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main.id
}

# route table association for public subnet
resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.route_table_public.id
}

# route table association for private subnet
resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.route_table_private.id
}

# route table association for database subnet
resource "aws_route_table_association" "database" {
  count = length(var.database_subnet_cidrs)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.route_table_database.id
}