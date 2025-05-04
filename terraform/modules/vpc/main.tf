########データソースの宣言########

data "aws_availability_zones" "available" {
  state = "available"
}

######## vpc ########
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpccidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.project_name}-vpc"
  }
}

######## internet gateway ########
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.project_name}-igw"
  }
}

######## subnet ########
resource "aws_subnet" "public_subnet_1" {
  availability_zone       = element(data.aws_availability_zones.available.names, 0)
  cidr_block              = var.public_subnet_1_cidr
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project_name}-PublicSubnet1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  availability_zone       = element(data.aws_availability_zones.available.names, 1)
  cidr_block              = var.public_subnet_2_cidr
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project_name}-PublicSubnet2"
  }
}

resource "aws_subnet" "private_subnet_1" {
  availability_zone = element(data.aws_availability_zones.available.names, 0)
  cidr_block        = var.private_subnet_1_cidr
  vpc_id            = aws_vpc.vpc.id
  tags = {
    Name = "${var.project_name}-PrivateSubnet1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  availability_zone = element(data.aws_availability_zones.available.names, 1)
  cidr_block        = var.private_subnet_2_cidr
  vpc_id            = aws_vpc.vpc.id
  tags = {
    Name = "${var.project_name}-PrivateSubnet2"
  }
}

resource "aws_subnet" "private_subnet_3" {
  availability_zone = element(data.aws_availability_zones.available.names, 0)
  cidr_block        = var.private_subnet_3_cidr
  vpc_id            = aws_vpc.vpc.id
  tags = {
    Name = "${var.project_name}-PrivateSubnet3"
  }
}

resource "aws_subnet" "private_subnet_4" {
  availability_zone = element(data.aws_availability_zones.available.names, 1)
  cidr_block        = var.private_subnet_4_cidr
  vpc_id            = aws_vpc.vpc.id
  tags = {
    Name = "${var.project_name}-PrivateSubnet4"
  }
}


######## route table ########
resource "aws_route_table" "public_route_table_1" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.project_name}-PublicRouteTable1"
  }
}

resource "aws_route_table" "public_route_table_2" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.project_name}-PublicRouteTable2"
  }
}

resource "aws_route_table" "private_route_table_1" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.project_name}-PrivateRouteTable1"
  }
}

resource "aws_route_table" "private_route_table_2" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.project_name}-PrivateRouteTable2"
  }
}

resource "aws_route_table" "private_route_table_3" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.project_name}-PrivateRouteTable3"
  }
}

resource "aws_route_table" "private_route_table_4" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.project_name}-PrivateRouteTable4"
  }
}

######## public route ########
resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table_1.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

######## routetable with subnet ########
resource "aws_route_table_association" "public_subnet_route_1_table_association" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table_1.id
}

resource "aws_route_table_association" "public_subnet_route_2_table_association" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table_2.id
}

resource "aws_route_table_association" "private_subnet_route_1_table_association" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table_1.id
}

resource "aws_route_table_association" "private_subnet_route_2_table_association" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table_2.id
}

resource "aws_route_table_association" "private_subnet_route_3_table_association" {
  subnet_id      = aws_subnet.private_subnet_3.id
  route_table_id = aws_route_table.private_route_table_3.id
}

resource "aws_route_table_association" "private_subnet_route_4_table_association" {
  subnet_id      = aws_subnet.private_subnet_4.id
  route_table_id = aws_route_table.private_route_table_4.id
}


