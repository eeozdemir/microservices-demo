resource "aws_vpc" "eks_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "kl-eks-vpc"
  }
}

# eu-west-1a az'de public subnet
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "kl-eks-public-subnet-1"
  }
}

# eu-west-1b az'de public subnet2
resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-west-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "kl-eks-public-subnet-2"
  }
}

# eu-west-1a az'de private subnet
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "kl-eks-private-subnet-1"
  }
}

# eu-west-1b az'de private subbnet2
resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "eu-west-1b"

  tags = {
    Name = "kl-eks-private-subnet-2"
  }
}

# public subnetler için IGW
resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "kl-eks-igw"
  }
}

# route table, public sub. internete çıkışı için 
resource "aws_route_table" "eks_public_rt" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "kl-eks-public-rt"
  }
}

resource "aws_route_table_association" "public_subnet_1_assoc" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.eks_public_rt.id
}

resource "aws_route_table_association" "public_subnet_2_assoc" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.eks_public_rt.id
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.eks_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.eks_igw.id
}

# private subnetler için NAT Gateway
resource "aws_eip" "eks_nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "eks_nat" {
  allocation_id = aws_eip.eks_nat_eip.id
  subnet_id     = aws_subnet.public_subnet_1.id

  tags = {
    Name = "kl-eks-nat"
  }
}

resource "aws_route_table" "eks_private_rt" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "kl-eks-private-rt"
  }
}

# private subnetlere NAT ile erişim
resource "aws_route" "private_internet_access" {
  route_table_id         = aws_route_table.eks_private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.eks_nat.id
}

resource "aws_route_table_association" "private_subnet_1_assoc" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.eks_private_rt.id
}

resource "aws_route_table_association" "private_subnet_2_assoc" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.eks_private_rt.id
}
