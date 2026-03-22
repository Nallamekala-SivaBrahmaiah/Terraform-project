resource "aws_s3_bucket" "storage" {
  bucket = var.bucket_name

  tags = var.tags
}