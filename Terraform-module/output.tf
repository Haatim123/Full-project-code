output "vpc_id" {  # This will output the value of vpc id in terminal
  value = aws_vpc.vpc-dev
}

output "Instance_id" { #This will output the value of the instance id terminal after terraform apply
  value = aws_instance.jenkins-server.id
}

output "Instance_ip" { #This will output the value of the instance public ip in terminal after terraform apply
  value = aws_instance.jenkins-server.public_ip
}