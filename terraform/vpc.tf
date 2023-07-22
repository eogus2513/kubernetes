resource "aws_vpc" "terraform-eks-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    "Name"                                      = "terraform-eks-vpc"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_subnet" "terraform-eks-public-subnet" {
  count = 2

  availability_zone       = "ap-northeast-2${count.index == 0 ? "a" : "c"}"
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.terraform-eks-vpc.id

  tags = {
    "Name"                                      = "terraform-eks-public-${count.index == 0 ? "a" : "c"}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_internet_gateway" "terraform-eks-igw" {
  vpc_id = aws_vpc.terraform-eks-vpc.id

  tags = {
    Name = "terraform-eks-igw"
  }
}

resource "aws_route_table" "terraform-eks-public-rtb" {
  vpc_id = aws_vpc.terraform-eks-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform-eks-igw.id
  }

  tags = {
    "Name" = "terraform-eks-public-rtb"
  }
}

resource "aws_route_table_association" "terraform-eks-rtb-association" {
  count = 2

  subnet_id      = aws_subnet.terraform-eks-public-subnet[count.index].id
  route_table_id = aws_route_table.terraform-eks-public-rtb.id
}
