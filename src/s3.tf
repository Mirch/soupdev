resource "aws_s3_bucket" "suppdev-client" {
  bucket = "suppdev-client"
}

resource "aws_s3_bucket_website_configuration" "suppdev-client" {
  bucket = aws_s3_bucket.suppdev-client.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
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
