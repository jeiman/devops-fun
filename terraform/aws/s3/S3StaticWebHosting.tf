# Static Website Hosting
variable "static_hosting_bucket_name" {
  type = string
}

resource "aws_s3_bucket" "b" {
  bucket = var.static_hosting_bucket_name
  acl    = "public-read"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${var.static_hosting_bucket_name}/*"
    }
  ]
}
POLICY

  website {
    index_document = "index.html"
    error_document = "error.html"
    routing_rules = <<EOF
    [{
        "Condition": {
            "KeyPrefixEquals": "docs/"
        },
        "Redirect": {
            "ReplaceKeyPrefixWith": "documents/"
        }
    }]
    EOF
  }
}