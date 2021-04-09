resource "aws_s3_bucket" "public_storage" {
  bucket = "storage.myjoruneysalud.com"
  acl    = "public-read"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST", "GET"]
    allowed_origins = [
      "https://app.myjourneysalud.com",
      "https://api.myjourneysalud.com"
    ]
    #expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}