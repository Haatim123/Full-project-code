resource "aws_dynamodb_table" "dynamodb-dev" {
  name = var.dynamodb_name
  read_capacity = 5
  write_capacity = 5
  hash_key = var.hash_key
  attribute {
    name = var.hash_key
    type = "S"
  }
  tags = {
    namee = "DynamoDB for Locking and unlocking"
  }
}