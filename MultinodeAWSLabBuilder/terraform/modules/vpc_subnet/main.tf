data "aws_canonical_user_id" "current" {}
data "aws_caller_identity" "current" {}

#Get the available AZ's so we can create subnets in separate AZ's
data "aws_availability_zones" "available" {
  state = "available"
}

#Create our VPC Resource
resource "aws_vpc" "Website_Default" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "Main VPC"
  }
}

#Create pur IGW Which allows our VPC to communicate with the internet.
resource "aws_internet_gateway" "IGW_Gateway" {
  vpc_id = aws_vpc.Website_Default.id
  tags = {
    Name = "Internet Gateway"
  }
  depends_on = [aws_vpc.Website_Default]
}

#Subnet creations in different AZ's
resource "aws_subnet" "subnet1" {
  vpc_id            = aws_vpc.Website_Default.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "Main Subnet"
    Tier = "Public"
  }
  depends_on = [aws_vpc.Website_Default]
}

resource "aws_subnet" "subnet2" {
  vpc_id            = aws_vpc.Website_Default.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "Additional Subnet"
    Tier = "Public"
  }
  depends_on = [aws_vpc.Website_Default]
}

#Create our route table from the VPC to our IGW and attach the route table to the subnets we created above.
resource "aws_default_route_table" "this" {
  default_route_table_id = aws_vpc.Website_Default.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW_Gateway.id
  }
  tags = {
    Name = "default route table"
  }
  depends_on = [aws_vpc.Website_Default]
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_default_route_table.this.id

  depends_on = [aws_subnet.subnet1]
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_default_route_table.this.id

  depends_on = [aws_subnet.subnet1]
}

#Create a Security Group which allows inbound SSH and HTTP connections.
resource "aws_security_group" "inbound_ssh_and_http" {
  name        = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.Website_Default.id
  description = "Allows inbound http connections"

  ingress { #SSH
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress { #HTTP
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress { #HTTPS
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
