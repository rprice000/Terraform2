provider "aws" {
  region = "us-east-2"
}

### 1. VPC ###
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "MainVPC"
  }
}

### 2. DHCP Option Set ###
resource "aws_vpc_dhcp_options" "main_dhcp_options" {
  domain_name         = "ec2.internal" # Adjust based on your requirements
  domain_name_servers = ["AmazonProvidedDNS"]

  tags = {
    Name = "Main-DHCP-Options"
  }
}

resource "aws_vpc_dhcp_options_association" "main_dhcp_options_assoc" {
  vpc_id          = aws_vpc.main_vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.main_dhcp_options.id
}

resource "aws_iam_role" "nat_instance_role" {
  name = "NAT-Instance-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "NAT-Instance-Role"
  }
}

### Attach SSM Policies to NAT Role ###
resource "aws_iam_role_policy_attachment" "nat_ssm_managed_policy" {
  role       = aws_iam_role.nat_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "nat_ec2_ssm_policy" {
  role       = aws_iam_role.nat_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

### IAM Instance Profile for NAT Instance ###
resource "aws_iam_instance_profile" "nat_instance_profile" {
  name = "NAT-Instance-Profile"
  role = aws_iam_role.nat_instance_role.name
}


resource "aws_iam_role" "wordpress_role" {
  name = "WordPress-Instance-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "WordPress-Instance-Role"
  }
}

### Attach SSM Policies to WordPress Role ###
resource "aws_iam_role_policy_attachment" "wordpress_ssm_managed_policy" {
  role       = aws_iam_role.wordpress_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "wordpress_ec2_ssm_policy" {
  role       = aws_iam_role.wordpress_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

### Attach ALB Describe Policy to WordPress Role ###
resource "aws_iam_policy" "alb_describe_policy" {
  name        = "ALBDescribePolicy"
  description = "Allows WordPress instance to describe ALBs"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "elasticloadbalancing:DescribeLoadBalancers"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "wordpress_alb_describe_attachment" {
  role       = aws_iam_role.wordpress_role.name
  policy_arn = aws_iam_policy.alb_describe_policy.arn
}

### IAM Instance Profile for WordPress Instance ###
resource "aws_iam_instance_profile" "wordpress_instance_profile" {
  name = "WordPress-Instance-Profile"
  role = aws_iam_role.wordpress_role.name
}






### 3. Internet Gateway ###
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "MainIGW"
  }
}

### 4. Subnets ###
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

### 5. Elastic IP ###
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = {
    Name = "NAT_EIP"
  }
}

### 6. Route Tables ###
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

##################################
### 7. Network ACLs ###
resource "aws_default_network_acl" "main_nacl" {
  default_network_acl_id = aws_vpc.main_vpc.default_network_acl_id
  tags = {
    Name     = "MAIN-NACL"
    UsageTag = "NOT-USED"
  }
}

### Public Subnet NACL ###
resource "aws_network_acl" "public_nacl" {
  vpc_id = aws_vpc.main_vpc.id

  # Inbound Rules
  ingress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    rule_no    = 110
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "10.0.3.0/24"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    rule_no    = 120
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "10.0.3.0/24"
    from_port  = 443
    to_port    = 443
  }

  ingress {
    rule_no    = 130
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  ingress {
    rule_no    = 140
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "10.0.3.0/24"
    from_port  = 1024
    to_port    = 65535
  }

  # Outbound Rules
  egress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    rule_no    = 110
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "10.0.3.0/24"
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    rule_no    = 120
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  egress {
    rule_no    = 130
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  egress {
    rule_no    = 140
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
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

### Private Subnet NACL ###
resource "aws_network_acl" "private_nacl" {
  vpc_id = aws_vpc.main_vpc.id

  # Inbound Rules
  ingress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "10.0.1.0/24"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    rule_no    = 120
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "10.0.1.0/24"
    from_port  = 1024
    to_port    = 65535
  }

  ingress {
    rule_no    = 130
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  ingress {
    rule_no    = 140
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "10.0.3.0/24"
    from_port  = 3306
    to_port    = 3306
  }

  # Outbound Rules
  egress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "10.0.1.0/24"
    from_port  = 0
    to_port    = 0
  }

  egress {
    rule_no    = 110
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  egress {
    rule_no    = 120
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  egress {
    rule_no    = 130
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "10.0.1.0/24"
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    rule_no    = 140
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "10.0.3.0/24"
    from_port  = 3306
    to_port    = 3306
  }

  tags = {
    Name = "Private-NACL"
  }
}

resource "aws_network_acl_association" "private_subnet_1_assoc" {
  subnet_id      = aws_subnet.private_subnet_1.id
  network_acl_id = aws_network_acl.private_nacl.id
}
#########################################################

### 8. Security Groups ###
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

### 9. Security Group Rules ###
# Inbound Rules for NAT EC2
resource "aws_security_group_rule" "nat_inbound_ssh" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.nat_sg.id
}

resource "aws_security_group_rule" "nat_inbound_all_traffic_private" {
  type        = "ingress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["10.0.3.0/24"]
  security_group_id = aws_security_group.nat_sg.id
}

resource "aws_security_group_rule" "nat_inbound_icmp" {
  type        = "ingress"
  from_port   = -1
  to_port     = -1
  protocol    = "icmp"
  cidr_blocks = ["10.0.3.0/24"]
  security_group_id = aws_security_group.nat_sg.id
}

# Outbound Rules for NAT EC2
resource "aws_security_group_rule" "nat_outbound_all" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.nat_sg.id
}

resource "aws_security_group_rule" "nat_outbound_ssh_wordpress" {
  type                     = "egress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.wordpress_sg.id
  security_group_id        = aws_security_group.nat_sg.id
}

resource "aws_security_group_rule" "nat_outbound_http" {
  type        = "egress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.nat_sg.id
}

resource "aws_security_group_rule" "nat_outbound_https" {
  type        = "egress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.nat_sg.id
}

resource "aws_security_group_rule" "nat_outbound_custom_tcp" {
  type                     = "egress"
  from_port                = 1024
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.wordpress_sg.id
  security_group_id        = aws_security_group.nat_sg.id
}

################################################
# Inbound Rules for ALB
resource "aws_security_group_rule" "alb_inbound_http" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "alb_inbound_https" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_sg.id
}

# Outbound Rules for ALB
resource "aws_security_group_rule" "alb_outbound_all" {
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.wordpress_sg.id
  security_group_id        = aws_security_group.alb_sg.id
}
####################################################
# Inbound Rules for WordPress
resource "aws_security_group_rule" "wordpress_inbound_http" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb_sg.id
  security_group_id        = aws_security_group.wordpress_sg.id
}

resource "aws_security_group_rule" "wordpress_inbound_https" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb_sg.id
  security_group_id        = aws_security_group.wordpress_sg.id
}

resource "aws_security_group_rule" "wordpress_inbound_ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.nat_sg.id
  security_group_id        = aws_security_group.wordpress_sg.id
}

resource "aws_security_group_rule" "wordpress_inbound_custom_tcp" {
  type                     = "ingress"
  from_port                = 1024
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.nat_sg.id
  security_group_id        = aws_security_group.wordpress_sg.id
}

resource "aws_security_group_rule" "wordpress_inbound_mysql" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.wordpress_sg.id
  security_group_id        = aws_security_group.wordpress_sg.id
}

# Outbound Rules for WordPress
resource "aws_security_group_rule" "wordpress_outbound_all" {
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.nat_sg.id
  security_group_id        = aws_security_group.wordpress_sg.id
}

resource "aws_security_group_rule" "wordpress_outbound_mysql" {
  type                     = "egress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.wordpress_sg.id
  security_group_id        = aws_security_group.wordpress_sg.id
}


resource "aws_instance" "nat_instance" {
  ami           = "ami-08970251d20e940b0" # Replace with Amazon Linux 2023 AMI ID for your region
  instance_type = "t2.micro"
  key_name      = "test_key" # Name of your manually created key pair
  subnet_id     = aws_subnet.public_subnet_1.id
  associate_public_ip_address = true
  security_groups = [aws_security_group.nat_sg.id]
  source_dest_check = false

  iam_instance_profile = aws_iam_instance_profile.nat_instance_profile.name # Attach NAT IAM Role
  tags = {
    Name = "NAT-Instance"
  }
}

resource "aws_eip_association" "nat_eip_assoc" {
  instance_id   = aws_instance.nat_instance.id
  allocation_id = aws_eip.nat_eip.id
}

resource "aws_route" "private_route_to_nat" {
  route_table_id         = aws_route_table.private_rt_1.id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_instance.nat_instance.primary_network_interface_id

  depends_on = [aws_instance.nat_instance]
}

resource "aws_instance" "wordpress_instance" {
  ami           = "ami-0cb91c7de36eed2cb" # Replace with Ubuntu Server 24.04 AMI ID for your region
  instance_type = "t2.micro"
  key_name      = "test_key" # Name of your manually created key pair
  subnet_id     = aws_subnet.private_subnet_1.id
  associate_public_ip_address = false
  security_groups = [aws_security_group.wordpress_sg.id]

  iam_instance_profile = aws_iam_instance_profile.wordpress_instance_profile.name # Attach WordPress IAM Role
  tags = {
    Name = "WordPress-Instance"
  }
}



### 18. Create Target Group ###
resource "aws_lb_target_group" "wordpress_tg" {
  name        = "wordpress-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main_vpc.id
  target_type = "instance"

  health_check {
    path                = "/var/www/demo/index.php"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "WordPress-TargetGroup"
  }
}

### Register Targets to Target Group ###
resource "aws_lb_target_group_attachment" "wordpress_target_attachment" {
  target_group_arn = aws_lb_target_group.wordpress_tg.arn
  target_id        = aws_instance.wordpress_instance.id
  port            = 80
}

### Configure Application Load Balancer ###
resource "aws_lb" "wordpress_alb" {
  name               = "wordpress-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets           = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]

  tags = {
    Name = "WordPress-ALB"
  }
}

### ALB Listener ###
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.wordpress_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wordpress_tg.arn
  }
}
