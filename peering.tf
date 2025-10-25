resource "aws_vpc_peering_connection" "vpc_peering" {
  count = var.is_peering_required ? 1 : 0
  peer_vpc_id   = data.aws_vpc.default.id  # Acceptor VPC ID (target VPC)
  vpc_id        = aws_vpc.main.id

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  auto_accept = true

  tags = merge(
    local.common_tags,
    {
      Name = "${local.common_name}-default"
    }
  )
} 

resource "aws_route" "public_to_default_vpc" {
  count = var.is_peering_required ? 1 : 0
  route_table_id            = aws_route_table.route_table_public.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vpc_peering[count.index].id}"
}

resource "aws_route" "default_vpc_to_public" {
  count = var.is_peering_required ? 1 : 0
  route_table_id            = data.aws_route_table.main.id
  destination_cidr_block    = var.vpc_cidr_block
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vpc_peering[count.index].id}"
}