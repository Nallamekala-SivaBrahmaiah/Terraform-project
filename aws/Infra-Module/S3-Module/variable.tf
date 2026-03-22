variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "tags" {
  description = "Tags for the bucket"
  type        = map(string)
  default     = {}
}