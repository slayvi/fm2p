
# Create an S3 bucket
resource "aws_s3_bucket" "bucketfm2p" {
  bucket = "bucketfm2p"
  force_destroy = true
}

# Create an S3 bucket
resource "aws_s3_bucket" "bucketlogsfm2p" {
  bucket = "bucketlogsfm2p"
  force_destroy = true
}
