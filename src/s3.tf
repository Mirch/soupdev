resource "aws_s3_bucket" "suppdev-client" {
  bucket = "suppdev-client"
}

resource "aws_s3_bucket_website_configuration" "suppdev-client-web-config" {
  bucket = aws_s3_bucket.suppdev-client.bucket

  index_document {
    suffix = "index.html"
  }
}

resource "null_resource" "upload-website" {
  provisioner "local-exec" {
    command = format("cd ./client && npm build && aws s3 sync ./client/build s3://%s", aws_s3_bucket.suppdev-client.bucket)
  }
}