#Variables for DB, value are assingned in .tfvars file
variable "db engine" {
type = string
default = ""
}
variable "db_engine_version" {
  type = string
  default = ""
}
variable "db_name" {
  type = string
  default = ""
}
variable "db_username" {
  type = string
  default = ""
}
variable "db_password" {
  type = string
  default = ""
}
variable "db_storage_type" {
  type = string
  default = ""
}
variable "db_subnet_group_name" {
  type = string
  default = ""
}


#Fetch private subnets from AWS account -
data "aws_subnets" "Available-private_subnets" {# we are fetching subnets from our account where name is Private-*
  filter {              # Here we are filtering for the subnet whose tag name start with Private-*
    name = "tag:Name"
    values = ["private-*"]
  }
}

resource "aws_db_subnet_group" "db_subnet" {  #  Here we are creating the db subnet group which is necessory to launch RDS instance
  name = var.db_subnet_group_name   #name of db-subnet-group
  subnet_ids = data.aws_availability_zones.available  # we are using list of subnets that we fetched above
#   subnet_ids = ["$(aws_subnet.private_subnet1-id)", "$(aws_subnet.private_subnet2.id)"]   #instead of fetching from account we can directly list subnet ids as well.
  tags = {
    name = var.environment
  }
}

resource "aws_db_instance" "RDS-db-instance" { # "aws_db_instance" api help to create new DB instance
  allocated_storage = 10 GB    # 10GB of Allocated storage out of 100TB
  engine =  var.db engine      # which database to use for example mysql , postgressql etc
  engine_version = var.db_engine_version   # which version of mysql, it must be availbal in console
  db_name = var.db_name         #databse name
  multi_az = true  #whether to deploy(create) db in multi az
  db_subnet_group_name = aws_db_subnet_group.db_subnet.name  #name of subnet group --fetched from aws account
  instance_class = "db.t2.micro"  #which instance to use for launching DB instance
  username = var.db_username  # username of the databse
  password = var.db_password  # password of the databse
  skip_final_snapshot = true  # whether to skip final snapshot or not
  storage_type = var.db_storage_type #which storage type to use
  vpc_security_group_ids = [aws_security_group.private_suecurity_group.id] #which security group to use
  
  tags = {
    name = var.db_name
    Environment =  var.environment
  }


}