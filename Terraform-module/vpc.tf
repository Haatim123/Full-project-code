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
  cidr_block              = var.public_subnet_cidr_values  # This will be the CIDR for subnet fetched from variable.tf
  map_public_ip_on_launch = true  # this will provide public ip address to instance when launched this subnet
  availability_zone               = data.aws_availability_zones.available.names[0] # for creating another subnet we need to add data.aws_availability_zones.available.names[1]
  tags = { # This is the list of tags
    Name : "Our-Public-Subnet" # subnet name
    Environment : var.environment # subnet environment
  }
}

#creating 2 subnet in each az 
resource "aws_subnet" "public_subnets" { #if we want to create 2 subnets in each AZ
  for_each = {
    "AZ1-Subnet1" = { az = data.aws_availability_zones.available.names[0], cidr = var.public_subnet_cidr_values[0] }
    "AZ1-Subnet2" = { az = data.aws_availability_zones.available.names[0], cidr = var.public_subnet_cidr_values[1] }
    "AZ2-Subnet1" = { az = data.aws_availability_zones.available.names[1], cidr = var.public_subnet_cidr_values[2] }
    "AZ2-Subnet2" = { az = data.aws_availability_zones.available.names[1], cidr = var.public_subnet_cidr_values[3] }
  }

  vpc_id                  = aws_vpc.vpc_dev.id
  cidr_block              = each.value.cidr
  map_public_ip_on_launch = true    # this will provide public ip address to instance when launched this subnet
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
resource "aws_subnet" "private_subnet1" {
    for_each = tomap({
        for index, az in slice(data.data.aws_availability_zones.available.names,1,3) : az => var.var.private_subnet_cidr_values[index]
    })
  vpc_id = aws_vpc.vpc-dev.id
  cidr_block = each.value
  map_customer_owned_ip_on_launch = false  # This is private subnet so no need of public ip
  availability_zone = each.key
  tags = {
    name = "praivate-subnet-${each.key}"
    environment = var.environment
  }
}

# Route table for public subnet 
resource "aws_route_table" "public_route_table" { # 1 public route table is sufficient to handle all subnets across multiple AZs"
  vpc_id = aws_vpc.vpc_dev.id #new route table will be created in this vpc 
  tags ={
    name =  "public-route-table"
    environment = var.environment
  }
}

# Route table for private subnet 
resource "aws_route_table" "private_route_table1" { #for private subnet we require sepearate route table for each subnet
    vpc_id = aws_vpc.vpc-dev.id 
    tags ={
        name = "private-route-table1"
        environment = var.environment
    }
}

resource "aws_route_table" "private_route_table2" { #for private subnet we require sepearate route table for each subnet
    vpc_id = aws_vpc.vpc-dev.id
    tags ={
        name = "private-route-table2"
        environment = var.environment
    }
}

# Subnet route table association
resource "aws_route_table_association" "public_route_table_association_1" { 
    subnet_id = aws_subnet.public_subnet_1                # this piblic is associated with public route table
    route_table_id = aws_route_table.public_route_table   # public route table id
  
}
resource "aws_route_table_association" "public_route_table_association_2" { 
    subnet_id = aws_subnet.public_subnet_2               # this piblic is associated with public route table
    route_table_id = aws_route_table.public_route_table  # same route id is used because for public subnets we require route table only.
  
}
resource "aws_route_table_association" "private_route_table1" {
     subnet_id = aws_subnet.private_subnet1                # private subnet is associated with private route table
     route_table_id = aws_route_table.private_route_table1 #  private route table id 

}
resource "aws_route_table_association" "private_route_table2" { # private subnet is associated with private route table
     subnet_id = aws_subnet.private_subnet2
     route_table_id = aws_route_table.private_route_table2   #  private route table id 


}

#create NAT gateway 
# Create a NAT Gateway in a public subnet (you need to create an Elastic IP for the NAT Gateway)
resource "aws_nat_gateway" "nat_gw" { #if cost is higher priority than availability, we use one NAT for multiple AZ, if Availability is priority we use sepearte NATs in each AZ. we need elastic IP for each NAT in each AZ. 
  allocation_id = aws_eip.nat_eip.id #elastic ip
  subnet_id     = aws_subnet.public_subnet_1.id
}

# AWS route addition into route tables
  resource "aws_route" "public_route_addition" { # This will create routes inside route table
  route_table_id = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.IGW-dev #one IGW for all AZs is suffucient.

}

resource "aws_route" "private_route_addition1" {
  route_table_id = aws_route_table.private_route_table1
  nat_gateway_id = aws_nat_gateway.nat_gw.id #one NAT gateway is used -->pro: cost effective  cons: single point of failue, may lead to loss of internet connection in multuple private subnet. cross AZ data transfer also applied and may face latency.
  destination_cidr_block = "0.0.0.0/0"
}
resource "aws_route" "private_route_addition2" {
  route_table_id = aws_route_table.private_route_table2
  nat_gateway_id = aws_nat_gateway.nat_gw.id #if we use two NAT gateways -->pro: HA, Reduced cross AZ data transfer charges,no-cross az latency cons: Higher cost  
  destination_cidr_block = "0.0.0.0/0"
}

#AWS security group 
resource "aws_security_group" "public_subnet_sg" {
   name = "security-group-${var.environment}"
   description = "public security group which defines traffic rule for resources"
   vpc_id = aws_vpc.vpc-dev
   tags = {
     name = "security-group-${var.environment}"
     environment = var.environment
   }
   ingress = [  # This is for inbound rules in SG
    {
     from_port = 22 #This is syntax to open port 22 for SSH connectivity
     to_port = 22
     protocol = "TCP" # port 22 uses SSH but we mention TCP here
     cidr_blocks = ["0.0.0.0/0"]  #To allow traffic from anywhere ipv4
   },

  {
    from_port = 80 # This is syntax to open port 80 for htttp connectivity
    to_port = 80
    protocol = "TCP" # port 80 work for http but we mention here TCP
    cidr_blocks = ["0.0.0.0/0"] #To allow traffic from anywhere ipv4
  },
  {
    from_port = 8080 #This is syntax to open port 8080 for jenkins connectivity
    to_port = 8080
    protocol = "TCP" #port 8080 work for jenkins but we mention here TCP
    cidr_blocks = ["0.0.0.0/0"] #To allow traffic from anywhere ipv4
  }
 ]
  egress ={  # This is syntax to open ports for outbound traffic
  from_port = 0 #we are allowing all traffic for outbound
  to_port = 0 #we are allowing all traffic for outbound
  protocol = "-1" #all protocol
  cidr_blocks = ["0.0.0.0/0"] #anywhere ipv4
  ipv6_cidr_blocks =["::/0"] #anywhere ipv6

  } 
 
}
resource "aws_suecurity_group" "private_suecurity_group" {
  description = "Private security group apply rules on resources which are part of private security group"
  name = "praivte-security-group-${var.environment}"
  vpc_id = aws_vpc.vpc-dev.id
  tags = {
  name = "praivte-security-group-${var.environment}"
  environment = var.environment
  }
  ingress = {
    from_port = 5432
    to_port = 5432
    protocol = "TCP"
    aws_security_group = aws_security_group.public_subnet_sg.id # Allow traffic from public SG
  }
  egress ={
    from_port = 0 
    to_port = 0
    protocol = "-1" # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
     
}
# SGs are attached to instances, while NACLs are applied to subnets, regardless of the AZ.
# #NACL for Subnets

resource "aws_network_acl" "public_subnet_nacl" {
  vpc_id = aws_vpc.vpc-dev.id
  tags ={
    name = "Public-subnet-NACL-${var.environment}"
    environment = var.environment
  }
  ingress = [
    {
        from_port = 80 
        to_port = 80 # Allow HTTP
        protocol = "TCP"
        cidr_block = ["0.0.0.0/0" ]
        rule_no = "100"
        action = "allow"
    },
    {
        from_port = 443
        to_port =443 #Allow HTTPS
        protocol = "TCP"
        cidr_block = ["0.0.0.0/0" ]
        rule_no = "110"
        action = "allow"

    },
    {
        from_port = 22
        to_port =22 #Allow HTTPS
        protocol = "TCP"
        cidr_block = "our-office-ip/32"
        rule_no = "120"
        action = "allow"

    },
  ]
  egress = { 
    protocol = "-1"
    rule_no = "100"
    action = "allow"
    cidr_block = ["0.0.0.0/0" ]  # Allow all outbound
  }
}

resource "aws_network_acl" "private_subnet_nacl" {
  vpc_id = aws_vpc.vpc-dev.id
  tags ={
    name = "Private-subnet-NACL-${var.environment}"
    environment = var.environment
  }
  ingress = [
    {
        from_port = 0 
        to_port = 65535  # Allow HTTP
        protocol = "TCP"
        cidr_block = ["10.0.0.0/16"] # Allow traffic from within the VPC
        rule_no = "100"
        action = "allow"
    },
    {
        from_port = 0 
        to_port = 65535  #Allow HTTPS
        protocol = "TCP"
        cidr_block = aws_subnet.public_subnet.cidr_block
        rule_no = "110"
        action = "allow"

    },
  ]
  egress = { 
    protocol = "-1"
    rule_no = "100"
    action = "allow"
    cidr_block = ["0.0.0.0/0" ]  # Allow all outbound
  }
}
