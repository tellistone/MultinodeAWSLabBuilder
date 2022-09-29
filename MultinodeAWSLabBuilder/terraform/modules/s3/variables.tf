variable "region" {
  default     = "eu-west-2"
  type        = string
  description = "Region this Infrastructure is based in"
}

variable "bucket_name" {
  description = "The name of the S3 bucket."
  type        = string
  default     = "graylogkeybucket"
}

variable "public_key" {}