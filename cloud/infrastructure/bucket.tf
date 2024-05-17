# Data source to get the existing IAM user
data "aws_iam_user" "bucketfm2p-user" {
  user_name = "terraform1"
}

# Data source to get the current AWS account ID
data "aws_caller_identity" "current" {}

# Create the first S3 bucket (assuming it exists already)
resource "aws_s3_bucket" "bucketfm2p" {
  bucket = "bucketfm2p"
  force_destroy = true

}

# Create the policy for the first S3 bucket
resource "aws_s3_bucket_policy" "bucket_policy_fm2p" {
  bucket = aws_s3_bucket.bucketfm2p.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${data.aws_iam_user.bucketfm2p-user.user_name}"
        }
        Action = [
          "s3:*"
        ]
        Resource = [
          "${aws_s3_bucket.bucketfm2p.arn}/*",
          "${aws_s3_bucket.bucketfm2p.arn}"
        ]
      }
    ]
  })
}

# Create the new S3 bucket
resource "aws_s3_bucket" "bucketlogsfm2p" {
  bucket = "bucketlogsfm2p"
  force_destroy = true
}

# Create the policy for the new S3 bucket
resource "aws_s3_bucket_policy" "bucket_policy_logsfm2p" {
  bucket = aws_s3_bucket.bucketlogsfm2p.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${data.aws_iam_user.bucketfm2p-user.user_name}"
        }
        Action = [
          "s3:*"
        ]
        Resource = [
          "${aws_s3_bucket.bucketlogsfm2p.arn}/*",
          "${aws_s3_bucket.bucketlogsfm2p.arn}"
        ]
      }
    ]
  })
}

# Attach the AmazonS3FullAccess policy to the IAM user
resource "aws_iam_user_policy_attachment" "iam_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  user       = data.aws_iam_user.bucketfm2p-user.user_name
}
