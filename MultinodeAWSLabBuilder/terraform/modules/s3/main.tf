#Create an S3 bucket which is private and has versioning and encryption.
resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  acl    = "private"


  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  force_destroy = false
}

#Deny public access to our bucket.
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#Apply Bucket policy in policies.tf to bucket.
resource "aws_s3_bucket_policy" "this" {

  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.s3_bucket_policy.json

  depends_on = [
    aws_s3_bucket_public_access_block.this
  ]
}

# Upload Public Key to our new S3 bucket.
resource "aws_s3_bucket_object" "Public_Key" {
  bucket = aws_s3_bucket.this.id
  key    = "RSA Public Key"
  source = "../terraform/modules/security/keys/id_rsa.pub"
}