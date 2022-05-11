# GET PROFILE
resource "aws_lambda_function" "get_profile_lambda" {
  function_name = "GetProfile"

  source_code_hash = data.archive_file.get_profile_archive.output_base64sha256
  filename         = data.archive_file.get_profile_archive.output_path

  handler = "func"
  runtime = "provided"

  role = aws_iam_role.get_profile.arn

  environment {
    variables = {
      USERS_TABLE_NAME     = aws_dynamodb_table.users.name
      USERS_USERNAME_INDEX = "UsersUsernameIndex"
    }
  }
}

data "archive_file" "get_profile_archive" {
  type = "zip"

  source_file = var.get_profile_bin_path
  output_path = "get_profile.zip"
}