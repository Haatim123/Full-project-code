variable "vpc_cidr_value" {
  description = "CIDR value for VPC"
  type ="string" 
  default = "10.0.0.0/16"
}

variable "environment" {
  description = "environment type for which vpc is created"
  type = "string"
  default = "dev"
}

#subnet variables
variable "public_subnet_cidr_values"{
    description = "List of CIDR blocks for public subnet"
    type = list(string)
    default = ["10.0.0.0/24", "10.0.1.0/24"] 
}
#for manually creating subnet we net provide two variables with different cidr value
# ex: 
# variable "public-subnet-cidr-value" {
#   description = "CIDR for public subnet creation"
#   type        = string
#   default     = "10.0.0.0/24"
# }

# variable "public-subnet-cidr-value2" {
#   description = "CIDR for public subnet creation"
#   type        = string
#   default     = "10.0.3.0/24"
# }

variable "private_subnet_cidr_values"{
    description = "List of CIDR blocks for public subnet"
    type = list(string)
    default = ["10.0.2.0/24", "10.0.3.0/24"]
}

####################################################################
#DynamoDB Variables
####################################################################
variable "dynamodb_name" {
  description = "This is dynamodb name"
  type = string
  default = "DynamoDB-dev"
}

variable "hash_key" {
  description = "This is hash key of Dynamodb"
  type = string
  default = "LockID"
}