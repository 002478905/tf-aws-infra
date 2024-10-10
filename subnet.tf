# Public Subnets
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.csye6225_vpc.id
  cidr_block              = var.public_subnet_1_cidr
  availability_zone       = var.public_subnet_1_az
  map_public_ip_on_launch = true
  tags = {
    Name = var.public_subnet_1_name
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.csye6225_vpc.id
  cidr_block              = var.public_subnet_2_cidr
  availability_zone       = var.public_subnet_2_az
  map_public_ip_on_launch = true
  tags = {
    Name = var.public_subnet_2_name
  }
}

resource "aws_subnet" "public_subnet_3" {
  vpc_id                  = aws_vpc.csye6225_vpc.id
  cidr_block              = var.public_subnet_3_cidr
  availability_zone       = var.public_subnet_3_az
  map_public_ip_on_launch = true
  tags = {
    Name = var.public_subnet_3_name
  }
}

# Private Subnets
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.csye6225_vpc.id
  cidr_block        = var.private_subnet_1_cidr
  availability_zone = var.private_subnet_1_az
  tags = {
    Name = var.private_subnet_1_name
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.csye6225_vpc.id
  cidr_block        = var.private_subnet_2_cidr
  availability_zone = var.private_subnet_2_az
  tags = {
    Name = var.private_subnet_2_name
  }
}

resource "aws_subnet" "private_subnet_3" {
  vpc_id            = aws_vpc.csye6225_vpc.id
  cidr_block        = var.private_subnet_3_cidr
  availability_zone = var.private_subnet_3_az
  tags = {
    Name = var.private_subnet_3_name
  }
}
