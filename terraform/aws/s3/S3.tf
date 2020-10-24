# Private Bucket w/ Tags

provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_s3_bucket" "b" {
  bucket = "test-bucket"
  acl = "private"

  tags = {
    Name        = "Test Bucket"
    Environment = "Dev"
  }
}

# Public Read Bucket w/ Tags

resource "aws_s3_bucket" "b3" {
  bucket = "test2-bucket"
  acl = "public-read"

  tags = {
    Name        = "Test3 Bucket"
    Environment = "Stage"
  }
}