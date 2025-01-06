#VPC for dev-environment
resource "aws_vpc" "vpc-dev" {
  cidr_block = var.vpc_cidr_value
  tags = {
    Name: "vpc-dev",  # this is the name of the VPC
    environment: var.environment   # this is the environment in which we are launching the VPC
  }
}

#IGW 
resource "aws_internet_gateway" "IGW-dev" {
  vpc_id = aws_vpc.vpc-dev.id  #this will attach igw to VPC 
  tags ={
    Name = "IGW-dev" #name of Internet gateway
    environmrnt = var.environment # this is the environment in which we are launching the IGW
  }
}

#create Subnet across multiple az Type:1 -using tomap()
resource "aws_subnet" "public_subnet_1"{ # "public_subnet_1" is api help to create api
for_each = tomap({
  for index, az in slice(data.aws_availability_zones.available.names, 0, 2) : az => var.public_subnet_cidr_values[index]
})
vpc_id  = aws_vpc.vpc_dev.id     # creating subnet inside this vpc
cidr_block = each.value   # This will be the CIDR for subnet fetched from variable.tf
map_public_ip_on_launch = true    # this will provide public ip address to instance when launched this subnet
availability_zone = each.key # Subnet will span this az
tags = {
    name = "public-subnet-${each.key}"
    environment = var.environment
}
}

#create Subnet across multiple az Type:2 -using toset()
resource "aws_subnet" "our_public_subnet" {
 for_each = toset(slice(data.aws_availability_zones.available.names, 0, 2))  # First two AZs

  vpc_id                  = aws_vpc.our-vpc.id
  cidr_block              = var.public_subnet_cidr_values[element(keys(each.key), 0)]
  map_public_ip_on_launch = true
  availability_zone       = each.value
  tags = {
    Name        = "Our-Public-Subnet-${each.value}"
    Environment = var.environment
  }
}

#create Subnet across multiple az Type:3 - Manual 
resource "aws_subnet" "our-public-subnet" {  # "aws_subnet" is api help to create api
  vpc_id                  = aws_vpc.our-vpc.id  # creating subnet inside this vpc
  cidr_block              = var.public_subnet_cidr_values # This will be the CIDR for subnet fetched from variable.tf
  map_public_ip_on_launch = true  # this will provide public ip address to instance when launched this subnet
  availability_zone               = data.aws_availability_zones.available.names[0] # for creating another subnet we need to add data.aws_availability_zones.available.names[1]
  tags = { # This is the list of tags
    Name : "Our-Public-Subnet" # subnet name
    Environment : var.environment # subnet environment
  }
}

#creating 2 subnet in each az 
resource "aws_subnet" "public_subnets" {
  for_each = {
    "AZ1-Subnet1" = { az = data.aws_availability_zones.available.names[0], cidr = var.public_subnet_cidr_values[0] }
    "AZ1-Subnet2" = { az = data.aws_availability_zones.available.names[0], cidr = var.public_subnet_cidr_values[1] }
    "AZ2-Subnet1" = { az = data.aws_availability_zones.available.names[1], cidr = var.public_subnet_cidr_values[2] }
    "AZ2-Subnet2" = { az = data.aws_availability_zones.available.names[1], cidr = var.public_subnet_cidr_values[3] }
  }

  vpc_id                  = aws_vpc.vpc_dev.id
  cidr_block              = each.value.cidr
  map_public_ip_on_launch = true
  availability_zone       = each.value.az

  tags = {
    Name        = "public-subnet-${each.key}"
    Environment = var.environment
  }
}
# outcome: 
# {
#   "AZ1-Subnet1" = { az = "us-east-1a", cidr = "10.0.1.0/24" }
#   "AZ1-Subnet2" = { az = "us-east-1a", cidr = "10.0.2.0/24" }
#   "AZ2-Subnet1" = { az = "us-east-1b", cidr = "10.0.3.0/24" }
#   "AZ2-Subnet2" = { az = "us-east-1b", cidr = "10.0.4.0/24" }
# }

#Private subnet
resource "aws_subnet" "private_subnet" {
    for_each = tomap({
        for index, az in slice(data.data.aws_availability_zones.available.names,1,3) : az => var.var.private_subnet_cidr_values[index]
    })
  vpc_id = aws_vpc.vpc-dev.id
  cidr_block = each.value
  map_customer_owned_ip_on_launch = false
  availability_zone = each.key
  tags = {
    name = "praivate-subnet-${each.key}"
    environment = var.environment
  }
}

# Route table for public subnet 
resource "aws_route_table" "public_route_tabble" {
  vpc_id = aws_vpc.vpc_dev.id
  tags ={
    name =  "public-route-table"
    environment = var.environment
  }
}

# Route table for private subnet
resource "aws_route_table" "private_route_table1" {
    vpc_id = aws_vpc.vpc-dev.id
    tags ={
        name = "private-route-table1"
        environment = var.environment
    }
}

resource "aws_route_table" "private_route_table2" {
    vpc_id = aws_vpc.vpc-dev.id
    tags ={
        name = "private-route-table2"
        environment = var.environment
    }
}

# Subnet route table association
resource "aws_route_ta" "name" {
  
}