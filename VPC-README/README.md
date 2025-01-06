# Full-project-code

# Dyanamic creation of public subnets across multiple Availability zones: 
for_each = tomap({
    for index, az in data.aws_availability_zones.available.names[0:2] : az => var.public_subnet_cidr_values[index]
  })

# How It Works:
for_each with tomap:

Creates a map where:
1. Keys are AZ names (az).
2. Values are the corresponding CIDR blocks from var.public_subnet_cidr_values.

Example:
{
  "us-east-1a" = "10.0.1.0/24",
  "us-east-1b" = "10.0.2.0/24"
}

# Dynamic Resource Creation:
Terraform creates one aws_subnet resource for each key-value pair in the map.
each.key: The current AZ name (e.g., us-east-1a).
each.value: The corresponding CIDR block (e.g., 10.0.1.0/24).
Tags and Name: The Name tag uses the AZ name to uniquely identify each subnet.

# What Happens During Apply? 
1. Terraform fetches the first two AZs, for example: ["us-east-1a", "us-east-1b"].
2. Creates a map like : 
  {
  "us-east-1a" = "10.0.1.0/24",
  "us-east-1b" = "10.0.2.0/24"
}
3. Iterates over the map to create: 
A subnet in us-east-1a with CIDR 10.0.1.0/24.
A subnet in us-east-1b with CIDR 10.0.2.0/24.

# Generated Subnets Example:
Subnet 1:
Name: public-subnet-us-east-1a
AZ: us-east-1a
CIDR: 10.0.1.0/24

Subnet 2:
Name: public-subnet-us-east-1b
AZ: us-east-1b
CIDR: 10.0.2.0/24

**Meaning of syntax names[0:2]**
The syntax names[0:2] is called slice notation. It is used to extract a subset of elements from a list.
names: Refers to the list of availability zone names fetched by the data "aws_availability_zones" "available" block.
data "aws_availability_zones" "available" {
  state = "available"
}
This might produce a list like ["us-east-1a", "us-east-1b", "us-east-1c"].

[0:2]: 
Extracts a slice (subset) of elements from the list:
0: The starting index (inclusive).
2: The ending index (exclusive). The slice stops just before this index.
This results in the first two elements of the list.

Example: 
If names is: ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d"]
Then names[0:2] would return: ["us-east-1a", "us-east-1b"]

**Effective Usable IPs**
The actual number of usable IP addresses in a subnet is:
Usable IPs=Total IPs−5
CIDR Block	Total IPs	Reserved IPs	Usable IPs
/28	          16	          5	           11
/24	         256	          5	           251 --> we can deploy upto 251 resources in one subnet
/16	       65,536	          5	           65,531

![alt text](image.png)

**Resources That Use IP Addresses**
The following AWS resources consume an IP address when deployed in a subnet:

1. EC2 Instances:
   Each instance gets a private IP address.
   If map_public_ip_on_launch is enabled, a public IP is also assigned (but doesn’t consume a subnet IP).
2. Elastic Load Balancers (ELBs):
   Typically consume multiple IPs across subnets for high availability.
3. NAT Gateways:
   Each NAT gateway consumes one IP address in the subnet.
4. RDS Instances:
   Each database instance consumes an IP address.
5. Containers and Pods (ECS/EKS):
   Each task or pod can consume one or more IPs depending on the configuration.
6. Network Interfaces:
   Secondary ENIs attached to EC2 instances or other services also consume IPs.

**Why No from_port or to_port in NACL?**
In Security Groups, you define inbound and outbound rules with granular attributes like from_port and to_port because SGs operate at the instance level.
In NACLs, you define rules at the subnet level using port_range, which handles the port range as a single attribute.
ex: port_range {
    from = 80                           # HTTP port
    to   = 80
  }

  **Comparison of SGs and NACLs**
Feature	        Security Groups (SG)	              Network ACLs (NACLs)
Scope	          Instance-level	                      Subnet-level
Statefulness	  Stateful	                              Stateless
Rules	          Allow rules only	                      Allow and deny rules
Use Cases	     Fine-grained instance access	          Broad subnet-level filtering
