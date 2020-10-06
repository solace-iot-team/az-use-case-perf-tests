####################################################################################################
# NOTE: The following network resources will only get created if:
# The "subnet_id" variable is left "empty"
####################################################################################################




resource "aws_vpc" "sdkperf_vpc" {  
  count = var.subnet_id == "" ? 1 : 0

  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = "true"
  enable_dns_hostnames = "true"
  enable_classiclink = "false"
  tags = {
    Name    = "${var.tag_name_prefix}-sdkperf-vpc"
    Owner   = var.tag_owner
    Purpose = "sdkperf benchmarking"
    Days    = var.tag_days
  }
}

resource "aws_subnet" "sdkperf_subnet" {
  count = var.subnet_id == "" ? 1 : 0

  vpc_id = aws_vpc.sdkperf_vpc[0].id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "${var.aws_region}a"

  tags = {
      Name    = "${var.tag_name_prefix}-sdkperf-subnet"
      Owner   = var.tag_owner
      Purpose = "sdkperf benchmarking"
      Days    = var.tag_days
  }
}

resource "aws_internet_gateway" "sdkperf_gw"{
  count = var.subnet_id == "" ? 1 : 0

  vpc_id = aws_vpc.sdkperf_vpc[0].id
  tags = {
    Name    = "${var.tag_name_prefix}-sdkperf-gw"
    Owner   = var.tag_owner
    Purpose = "sdkperf benchmarking"
    Days    = var.tag_days
  }
}

resource "aws_route_table" "sdkperf_routetable"{
  count = var.subnet_id == "" ? 1 : 0

  vpc_id = aws_vpc.sdkperf_vpc[0].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sdkperf_gw[0].id
  }
  tags = {
    Name    = "${var.tag_name_prefix}-sdkperf-routetable"
    Owner   = var.tag_owner
    Purpose = "sdkperf benchmarking"
    Days    = var.tag_days
  }
}

resource "aws_route_table_association" "sdkperf_RTA"{
  count = var.subnet_id == "" ? 1 : 0

  subnet_id = aws_subnet.sdkperf_subnet[0].id
  route_table_id = aws_route_table.sdkperf_routetable[0].id
}
