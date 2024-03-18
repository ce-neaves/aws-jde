data "aws_availability_zones" "available" {}
# data "aws_region" "current" { current = true }
data "aws_region" "current" {}

resource "aws_vpc" "vpc01" {
    cidr_block = "${var.vpc_cidr}"
    enable_dns_hostnames = true

    tags = {
      Name = "terraform-aws-vpc"
      managed-by = "terraform"
      owner = "neaves"
      environment = "dev"
    }
}

resource "aws_internet_gateway" "gw" {
    vpc_id = "${aws_vpc.vpc01.id}"

    tags = {
      Name = "terraform-aws-vpc"
      managed-by = "terraform"
      owner = "neaves"
      environment = "dev"
    }
}

# NAT Gateways

resource "aws_eip" "eip_NAT1" {
  count = "${var.create_NATgws}"
  vpc      = true
}

resource "aws_nat_gateway" "nat_gw_AZ1" {
  # count = "${var.create_NATgws}"
  connectivity_type = "private"
  subnet_id     = "${aws_subnet.subnet_AZ1_public1.id}"

  tags = {
    Name = "Private Subnet AZ1 NGW"
    managed-by = "terraform"
    owner = "neaves"
    environment = "dev"
  }

  depends_on = [aws_internet_gateway.gw]
}

resource "aws_eip" "eip_NAT2" {
  count = "${var.create_NATgws}"
  vpc      = true
}

resource "aws_nat_gateway" "nat_gw_AZ2" {
  connectivity_type = "private"
  subnet_id     = "${aws_subnet.subnet_AZ2_public1.id}"

  tags = {
    Name = "Private Subnet AZ2 NGW"
    managed-by = "terraform"
    owner = "neaves"
    environment = "dev"
  }

  depends_on = [aws_internet_gateway.gw]
}


# Availability Zone 1 - Public Subnet

resource "aws_subnet" "subnet_AZ1_public1" {
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  cidr_block = "${var.subnetAZ1_public_cidr}"
  vpc_id     = "${aws_vpc.vpc01.id}"

  tags = {
    Name = "${data.aws_availability_zones.available.names[0]} - Public Subnet"
    managed-by = "terraform"
    owner = "neaves"
    environment = "dev"
  }
}

resource "aws_network_acl" "nacl_AZ1_public1" {
  vpc_id = "${aws_vpc.vpc01.id}"
  subnet_ids = ["${aws_subnet.subnet_AZ1_public1.id}"]

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "${data.aws_availability_zones.available.names[0]} - Public Subnet"
    managed-by = "terraform"
    owner = "neaves"
    environment = "dev"
  }
}

resource "aws_route_table" "route_table_AZ1_public1" {
  vpc_id = "${aws_vpc.vpc01.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags = {
    Name = "${data.aws_availability_zones.available.names[0]} - Public Subnet"
    managed-by = "terraform"
    owner = "neaves"
    environment = "dev"
  }
}

resource "aws_route_table_association" "route_assoc_AZ1_public1" {
  subnet_id      = "${aws_subnet.subnet_AZ1_public1.id}"
  route_table_id = "${aws_route_table.route_table_AZ1_public1.id}"
}


# Availability Zone 1 - Private Subnet

resource "aws_subnet" "subnet_AZ1_private1" {
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  cidr_block = "${var.subnetAZ1_private_cidr}"
  vpc_id     = "${aws_vpc.vpc01.id}"

  tags =  {
    Name = "${data.aws_availability_zones.available.names[0]} - Private Subnet"
    managed-by = "terraform"
    owner = "neaves"
    environment = "dev"
  }
}

resource "aws_network_acl" "nacl_AZ1_private1" {
  vpc_id = "${aws_vpc.vpc01.id}"
  subnet_ids = ["${aws_subnet.subnet_AZ1_private1.id}"]

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "${var.vpc_cidr}"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 500
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 32768
    to_port    = 65535
  }

  tags = {
    Name = "${data.aws_availability_zones.available.names[0]} - Private Subnet"
    managed-by = "terraform"
    owner = "neaves"
    environment = "dev"
  }
}

resource "aws_route_table" "route_table_AZ1_private1" {
  vpc_id = "${aws_vpc.vpc01.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat_gw_AZ1.id}"
  }

  tags = {
    Name = "${data.aws_availability_zones.available.names[0]} - Private Subnet"
    managed-by = "terraform"
    owner = "neaves"
    environment = "dev"
  }
}

resource "aws_route_table_association" "route_assoc_AZ1_private1" {
  subnet_id      = "${aws_subnet.subnet_AZ1_private1.id}"
  route_table_id = "${aws_route_table.route_table_AZ1_private1.id}"
}


# Availability Zone 1 - Private Data Subnet

resource "aws_subnet" "subnet_AZ1_private_data1" {
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  cidr_block = "${var.subnetAZ1_private_data_cidr}"
  vpc_id     = "${aws_vpc.vpc01.id}"

  tags = {
    Name = "${data.aws_availability_zones.available.names[0]} - Private Data Subnet"
    managed-by = "terraform"
    owner = "neaves"
    environment = "dev"
  }
}

resource "aws_network_acl" "nacl_AZ1_private_data1" {
  vpc_id = "${aws_vpc.vpc01.id}"
  subnet_ids = ["${aws_subnet.subnet_AZ1_private_data1.id}"]

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "${var.vpc_cidr}"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "${data.aws_availability_zones.available.names[0]} - Private Data Subnet"
    managed-by = "terraform"
    owner = "neaves"
    environment = "dev"
  }
}

resource "aws_route_table" "route_table_AZ1_private_data1" {
  vpc_id = "${aws_vpc.vpc01.id}"

  tags = {
    Name = "${data.aws_availability_zones.available.names[0]} - Private Data Subnet"
    managed-by = "terraform"
    owner = "neaves"
    environment = "dev"
  }
}

resource "aws_route_table_association" "route_assoc_AZ1_private_data1" {
  subnet_id      = "${aws_subnet.subnet_AZ1_private_data1.id}"
  route_table_id = "${aws_route_table.route_table_AZ1_private_data1.id}"
}


# Availability Zone 2 - Public Subnet

resource "aws_subnet" "subnet_AZ2_public1" {
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
  cidr_block = "${var.subnetAZ2_public_cidr}"
  vpc_id     = "${aws_vpc.vpc01.id}"

  tags = {
    Name = "${data.aws_availability_zones.available.names[1]} - Public Subnet"
    managed-by = "terraform"
    owner = "neaves"
    environment = "dev"
  }
}

resource "aws_network_acl" "nacl_AZ2_public1" {
  vpc_id = "${aws_vpc.vpc01.id}"
  subnet_ids = ["${aws_subnet.subnet_AZ2_public1.id}"]

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "${data.aws_availability_zones.available.names[1]} - Public Subnet"
    managed-by = "terraform"
    owner = "neaves"
    environment = "dev"
  }
}

resource "aws_route_table" "route_table_AZ2_public1" {
  vpc_id = "${aws_vpc.vpc01.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags = {
    Name = "${data.aws_availability_zones.available.names[1]} - Public Subnet"
    managed-by = "terraform"
    owner = "neaves"
    environment = "dev"
  }
}

resource "aws_route_table_association" "route_assoc_AZ2_public1" {
  subnet_id      = "${aws_subnet.subnet_AZ2_public1.id}"
  route_table_id = "${aws_route_table.route_table_AZ2_public1.id}"
}


# Availability Zone 2 - Private Subnet

resource "aws_subnet" "subnet_AZ2_private1" {
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
  cidr_block = "${var.subnetAZ2_private_cidr}"
  vpc_id     = "${aws_vpc.vpc01.id}"

  tags = {
    Name = "${data.aws_availability_zones.available.names[1]} - Private Subnet"
    managed-by = "terraform"
    owner = "neaves"
    environment = "dev"
  }
}

resource "aws_network_acl" "nacl_AZ2_private1" {
  vpc_id = "${aws_vpc.vpc01.id}"
  subnet_ids = ["${aws_subnet.subnet_AZ2_private1.id}"]

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "${var.vpc_cidr}"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 500
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 32768
    to_port    = 65535
  }

  tags = {
    Name = "${data.aws_availability_zones.available.names[1]} - Private Subnet"
    managed-by = "terraform"
    owner = "neaves"
    environment = "dev"
  }
}

resource "aws_route_table" "route_table_AZ2_private1" {
  vpc_id = "${aws_vpc.vpc01.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat_gw_AZ2.id}"
  }

  tags = {
    Name = "${data.aws_availability_zones.available.names[1]} - Private Subnet"
    managed-by = "terraform"
    owner = "neaves"
    environment = "dev"
  }
}

resource "aws_route_table_association" "route_assoc_AZ2_private1" {
  subnet_id      = "${aws_subnet.subnet_AZ2_private1.id}"
  route_table_id = "${aws_route_table.route_table_AZ2_private1.id}"
}


# Availability Zone 2 - Private Data Subnet

resource "aws_subnet" "subnet_AZ2_private_data1" {
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
  cidr_block = "${var.subnetAZ2_private_data_cidr}"
  vpc_id     = "${aws_vpc.vpc01.id}"

  tags = {
    Name = "${data.aws_availability_zones.available.names[1]} - Private Data Subnet"
    managed-by = "terraform"
    owner = "neaves"
    environment = "dev"
  }
}

resource "aws_network_acl" "nacl_AZ2_private_data1" {
  vpc_id = "${aws_vpc.vpc01.id}"
  subnet_ids = ["${aws_subnet.subnet_AZ2_private_data1.id}"]

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "${var.vpc_cidr}"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "${data.aws_availability_zones.available.names[1]} - Private Data Subnet"
    managed-by = "terraform"
    owner = "neaves"
    environment = "dev"
  }
}

resource "aws_route_table" "route_table_AZ2_private_data1" {
  vpc_id = "${aws_vpc.vpc01.id}"

  tags = {
    Name = "${data.aws_availability_zones.available.names[1]} - Private Data Subnet"
    managed-by = "terraform"
    owner = "neaves"
    environment = "dev"
  }
}

resource "aws_route_table_association" "route_assoc_AZ2_private_data1" {
  subnet_id      = "${aws_subnet.subnet_AZ2_private_data1.id}"
  route_table_id = "${aws_route_table.route_table_AZ2_private_data1.id}"
}


# S3 Endpoints  - All Subnets

resource "aws_vpc_endpoint" "private-s3" {
  vpc_id       = "${aws_vpc.vpc01.id}"
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"
  route_table_ids = [ "${aws_route_table.route_table_AZ1_public1.id}",
                    "${aws_route_table.route_table_AZ1_private1.id}",
                    "${aws_route_table.route_table_AZ1_private_data1.id}",
                    "${aws_route_table.route_table_AZ2_public1.id}",
                    "${aws_route_table.route_table_AZ2_private1.id}",
                    "${aws_route_table.route_table_AZ2_private_data1.id}"
                  ]
}


# VPC Flowlogs

resource "aws_flow_log" "flowlog-vpc01" {
  log_destination = "${aws_cloudwatch_log_group.log_group_vpc_flowlogs.arn}"
  iam_role_arn   = "${aws_iam_role.role-vpc-flowlog.arn}"
  vpc_id         = "${aws_vpc.vpc01.id}"
  traffic_type   = "ALL"
}

resource "aws_cloudwatch_log_group" "log_group_vpc_flowlogs" {
  name = "vpc-flowlogs"
}

resource "aws_iam_role" "role-vpc-flowlog" {
  name = "vpc-flowlog-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "vpc_flowlog_write" {
  name = "vpc_flowlog_write"
  role = "${aws_iam_role.role-vpc-flowlog.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
