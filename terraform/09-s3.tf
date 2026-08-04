resource "aws_s3_bucket" "executive_reports" {
  bucket = "executive-reports-bucket-july-2026"

  force_destroy = true

  tags = {
    Name        = "incident-bucket-july-2026"
    Environment = "Prod"
  }
}












































