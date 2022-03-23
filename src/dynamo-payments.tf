resource "aws_dynamodb_table" "payments" {
  name         = "Payments"
  hash_key     = "id"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "from"
    type = "S"
  }

  attribute {
    name = "to"
    type = "S"
  }

  attribute {
    name = "order_id"
    type = "S"
  }

  global_secondary_index {
    name            = "PaymentsFromIndex"
    hash_key        = "from"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "PaymentsToIndex"
    hash_key        = "to"
    projection_type = "ALL"
  }

    global_secondary_index {
    name            = "PaymentsOrderIdIndex"
    hash_key        = "order_id"
    projection_type = "ALL"
  }
}
