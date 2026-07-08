data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "app" {
  bucket = "etracker-tf-state-${data.aws_caller_identity.current.account_id}"

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
