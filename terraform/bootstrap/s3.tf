resource "aws_s3_bucket" "app" {
  bucket = "etracker-tf-state-20260716"

  tags = {
    Environment = "Dev"
    Purpose     = "Terraform state"
  }
}

resource "aws_s3_bucket_versioning" "app" {
  bucket = aws_s3_bucket.app.id

  versioning_configuration {
    status = "Enabled"
  }
}
