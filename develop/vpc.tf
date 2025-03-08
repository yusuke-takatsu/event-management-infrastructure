# ===============================================================================
# VPC
# ===============================================================================
resource "aws_vpc" "main" {
  cidr_block                       = "172.31.0.0/16"
  enable_dns_hostnames             = true
  enable_dns_support               = true
  instance_tenancy                 = "default"
  assign_generated_ipv6_cidr_block = false

  tags = {
    Name = "${local.project}-${local.env}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.project}-${local.env}"
  }
}

# ===============================================================================
# public subnet
# ===============================================================================
resource "aws_subnet" "public" {
  for_each                = toset(local.availability_zones)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 4, index(local.availability_zones, each.key))
  availability_zone       = each.key
  map_public_ip_on_launch = true
  tags = {
    Name = "${local.project}-${local.env}-public-${each.key}"
  }
}

resource "aws_route_table" "public" {
  for_each = toset(local.availability_zones)
  vpc_id   = aws_vpc.main.id

  lifecycle {
    ignore_changes = [
      route,
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-public-${each.key}"
  }
}

# 関連付け (Association)
resource "aws_route" "default_gw" {
  for_each = toset(local.availability_zones)
  route_table_id = aws_route_table.public[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  for_each = toset(local.availability_zones)
  subnet_id = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public[each.key].id
}
