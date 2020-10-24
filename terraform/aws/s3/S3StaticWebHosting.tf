# Static Website Hosting
resource "aws_s3_bucket" "webhosting" {
  bucket = "www.example.com"
  acl    = "public-read"
  # policy = "${file("policy.json")}"

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