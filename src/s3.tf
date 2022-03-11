resource "aws_s3_bucket" "suppdev-client" {
  bucket = "suppdev-client"
}

resource "aws_s3_bucket_website_configuration" "suppdev-client" {
  bucket = aws_s3_bucket.suppdev-client.bucket

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_acl" "suppdev-client" {
  bucket = aws_s3_bucket.suppdev-client.id

  acl = "public-read"
}

resource "aws_s3_bucket_policy" "suppdev-client" {
  bucket = aws_s3_bucket.suppdev-client.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource = [
          aws_s3_bucket.suppdev-client.arn,
          "${aws_s3_bucket.suppdev-client.arn}/*",
        ]
      },
    ]
  })
}

resource "null_resource" "upload-website" {
  provisioner "local-exec" {
    command = format("cd ./client && sudo apt-get install nodejs && sudo npm install && sudo npm build && aws s3 sync ./client/build s3://%s", aws_s3_bucket.suppdev-client.bucket)
  }
}