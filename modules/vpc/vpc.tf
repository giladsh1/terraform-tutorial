###############################################
###          create vpc resources           ###
###############################################

# get the current region for the provider
data "aws_region" "current" {
  current = true
}

# VPC
resource "aws_vpc" "vpc" {
    cidr_block           = "10.0.0.0/16"
    instance_tenancy     = "default"
    enable_dns_support   = "true"
    enable_dns_hostnames = "true"
    enable_classiclink   = "false"
    tags {
        Name = "${var.name}"
    }
}

# Subnets
resource "aws_subnet" "vpc-public-1" {
    vpc_id                  = "${aws_vpc.vpc.id}"
    cidr_block              = "10.0.1.0/24"
    map_public_ip_on_launch = "true"
    availability_zone       = "${data.aws_region.current.name}${var.az}"
    tags {
        Name = "${var.name}-public-1"
    }
}

# Internet GW
resource "aws_internet_gateway" "vpc-gw" {
    vpc_id = "${aws_vpc.vpc.id}"
    tags {
        Name = "${var.name}-gw"
    }
}

# Route tables
resource "aws_route_table" "vpc-rt" {
    vpc_id = "${aws_vpc.vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.vpc-gw.id}"
    }
    tags {
        Name = "${var.name}-public-1"
    }
}

# Route associations public
resource "aws_route_table_association" "vpc-rt-association" {
    subnet_id      = "${aws_subnet.vpc-public-1.id}"
    route_table_id = "${aws_route_table.vpc-rt.id}"
}

