provider "aws" {
  region = "us-east-2" # Replace with your desired region
}

### 1. VPC ###
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "MainVPC"
  }
}

### 2. Internet Gateway ###
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "MainIGW"
  }
}

### 3. Subnets ###
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "PublicSubnet1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-2b"
  map_public_ip_on_launch = true
  tags = {
    Name = "PublicSubnet2"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = false
  tags = {
    Name = "PrivateSubnet1"
  }
}

### 4. Elastic IP ###
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = {
    Name = "NAT_EIP"
  }
}

### 5. Route Tables ###
resource "aws_route_table" "public_rt_1" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "PublicRouteTable1"
  }
}

resource "aws_route_table" "public_rt_2" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "PublicRouteTable2"
  }
}

resource "aws_route_table_association" "public_association_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt_1.id
}

resource "aws_route_table_association" "public_association_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt_2.id
}

resource "aws_route_table" "private_rt_1" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }
  tags = {
    Name = "PrivateRouteTable1"
  }
}

resource "aws_route_table_association" "private_association_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_rt_1.id
}

resource "aws_default_route_table" "main_route_table" {
  default_route_table_id = aws_vpc.main_vpc.default_route_table_id

  tags = {
    Name     = "MAIN-RouteTable"
    UsageTag = "NOT-USED"
  }
}


### 6. Network ACLs ###
resource "aws_default_network_acl" "main_nacl" {
  default_network_acl_id = aws_vpc.main_vpc.default_network_acl_id
  tags = {
    Name     = "MAIN-NACL"
    UsageTag = "NOT-USED"
  }
}

resource "aws_network_acl" "public_nacl" {
  vpc_id = aws_vpc.main_vpc.id

  egress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    rule_no    = 110
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  ingress {
    rule_no    = 120
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  tags = {
    Name = "Public-NACL"
  }
}

resource "aws_network_acl_association" "public_subnet_1_assoc" {
  subnet_id      = aws_subnet.public_subnet_1.id
  network_acl_id = aws_network_acl.public_nacl.id
}

resource "aws_network_acl_association" "public_subnet_2_assoc" {
  subnet_id      = aws_subnet.public_subnet_2.id
  network_acl_id = aws_network_acl.public_nacl.id
}

resource "aws_network_acl" "private_nacl" {
  vpc_id = aws_vpc.main_vpc.id

  egress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "10.0.1.0/24"
    from_port  = 0
    to_port    = 65535
  }

  ingress {
    rule_no    = 110
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "10.0.2.0/24"
    from_port  = 0
    to_port    = 65535
  }

  ingress {
    rule_no    = 120
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "10.0.3.0/24"
    from_port  = 0
    to_port    = 65535
  }

  tags = {
    Name = "Private-NACL"
  }
}

resource "aws_network_acl_association" "private_subnet_1_assoc" {
  subnet_id      = aws_subnet.private_subnet_1.id
  network_acl_id = aws_network_acl.private_nacl.id
}

### 7. Security Groups ###
resource "aws_security_group" "nat_sg" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "NAT-SG"
  }
}

resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "ALB-SG"
  }
}

resource "aws_security_group" "wordpress_sg" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "WordPress-SG"
  }
}

resource "aws_default_security_group" "main_security_group" {
  vpc_id = aws_vpc.main_vpc.id

  ingress = []
  egress  = []

  tags = {
    Name     = "MAIN-SecurityGroup"
    UsageTag = "NOT-USED"
  }
}

### Security Group Rules ###
resource "aws_security_group_rule" "nat_inbound_icmp" {
  type                     = "ingress"
  from_port                = -1
  to_port                  = -1
  protocol                 = "icmp"
  security_group_id        = aws_security_group.nat_sg.id
  source_security_group_id = aws_security_group.wordpress_sg.id
}

resource "aws_security_group_rule" "nat_inbound_all_traffic" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.nat_sg.id
  source_security_group_id = aws_security_group.wordpress_sg.id
}

resource "aws_security_group_rule" "nat_inbound_ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.nat_sg.id
  cidr_blocks              = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "nat_outbound_all_traffic" {
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.nat_sg.id
  cidr_blocks              = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "nat_outbound_ssh" {
  type                     = "egress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.nat_sg.id
  source_security_group_id = aws_security_group.wordpress_sg.id
}

resource "aws_security_group_rule" "alb_inbound_http" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.alb_sg.id
  cidr_blocks              = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_inbound_https" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.alb_sg.id
  cidr_blocks              = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_outbound_all_traffic" {
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.alb_sg.id
  source_security_group_id = aws_security_group.wordpress_sg.id
}

resource "aws_security_group_rule" "wordpress_inbound_ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.wordpress_sg.id
  source_security_group_id = aws_security_group.nat_sg.id
}

resource "aws_security_group_rule" "wordpress_inbound_http" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.wordpress_sg.id
  source_security_group_id = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "wordpress_inbound_https" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.wordpress_sg.id
  source_security_group_id = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "wordpress_outbound_all_traffic" {
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.wordpress_sg.id
  source_security_group_id = aws_security_group.nat_sg.id
}

resource "aws_security_group_rule" "wordpress_outbound_mysql" {
  type                     = "egress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.wordpress_sg.id
  cidr_blocks              = ["127.0.0.1/32"]
}