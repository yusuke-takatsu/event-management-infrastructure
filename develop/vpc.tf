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

