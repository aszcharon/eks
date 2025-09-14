locals {
  availability_zones = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c", "ap-northeast-2d"]
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-vpc"
  })
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-igw"
  })
}

resource "aws_subnet" "public" {
  count = 2

  vpc_id                  = aws_vpc.main.id
  cidr_block              = "192.168.${count.index}.0/24"
  availability_zone       = local.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-${var.environment}-public-${count.index + 1}"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "private_eks" {
  count = 2

  vpc_id            = aws_vpc.main.id
  cidr_block        = "192.168.${count.index + 10}.0/24"
  availability_zone = local.availability_zones[count.index]

  tags = {
    Name = "${var.project_name}-${var.environment}-private-eks-${count.index + 1}"
    "kubernetes.io/role/internal-elb" = "1"
    Type = "EKS"
  }
}

resource "aws_subnet" "private_rds" {
  count = 2

  vpc_id            = aws_vpc.main.id
  cidr_block        = "192.168.${count.index + 20}.0/24"
  availability_zone = local.availability_zones[count.index]

  tags = {
    Name = "${var.project_name}-${var.environment}-private-rds-${count.index + 1}"
    Type = "RDS"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"
  depends_on = [aws_internet_gateway.main]

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-eip"
  })
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-nat"
  })

  depends_on = [aws_internet_gateway.main]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-public-rt"
  })
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-private-rt"
  })
}

resource "aws_route_table_association" "public" {
  count = 2

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_eks" {
  count = 2

  subnet_id      = aws_subnet.private_eks[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_rds" {
  count = 2

  subnet_id      = aws_subnet.private_rds[count.index].id
  route_table_id = aws_route_table.private.id
}