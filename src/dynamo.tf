resource "aws_dynamodb_table" "users" {
  name         = "Users"
  hash_key     = "uid"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "uid"
    type = "S"
  }

  attribute {
    name = "username"
    type = "S"
  }

  global_secondary_index {
    name            = "UsersUsernameIndex"
    hash_key        = "username"
    projection_type = "ALL"
  }
}