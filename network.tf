resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Public Subnet for Ubuntu
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

# Private Subnet for Amazon Linux
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.2.0/24"
}

# Internet Gateway for Ubuntu to have internet access
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id
}

# Public Route Table for Ubuntu
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id
}

# Route for public internet access
resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Associate public subnet with public route table
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Security Group for Ubuntu
resource "aws_security_group" "ubuntu_sg" {
  vpc_id = aws_vpc.my_vpc.id

  # Allow SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Allow HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Allow HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Allow ICMP
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for Amazon Linux (no internet, only communication with Ubuntu)
resource "aws_security_group" "amazon_linux_sg" {
  vpc_id = aws_vpc.my_vpc.id

  # Allow SSH from Ubuntu
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.public_subnet.cidr_block]
  }
  # Allow HTTP from Ubuntu
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.public_subnet.cidr_block]
  }
  # Allow HTTPS from Ubuntu
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.public_subnet.cidr_block]
  }
  # Allow ICMP from Ubuntu
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [aws_subnet.public_subnet.cidr_block]
  }
  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {}

# NAT Gateway for private subnet to access the internet
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet.id

  # Ensure proper ordering with Internet Gateway
  depends_on = [aws_internet_gateway.igw]
}

# Private Route Table for Amazon Linux to access the internet via NAT
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.my_vpc.id
}

# Route for private subnet to access the internet via NAT
resource "aws_route" "private_nat_access" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

# Associate private subnet with private route table
resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}
