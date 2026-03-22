terraform {
  backend "s3" {
    bucket = "my-tf-test-bucket-123458"
    key    = ".tfstatefile"
    region = "ap-south-1"
  }
}
