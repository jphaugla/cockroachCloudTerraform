################################################################################
# storage.tf — Simple S3 bucket + EC2 role with read/write (toggle IAM creation)
################################################################################

################################################################################
# S3 Bucket
################################################################################

resource "aws_s3_bucket" "molt_bucket" {
  bucket        = local.bucket_name
  force_destroy = true

  tags = {
    Name    = local.bucket_name
    Owner   = var.owner
    Project = var.project_name
    Region  = var.aws_region
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.molt_bucket.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.molt_bucket.id
  rule { object_ownership = "BucketOwnerEnforced" }
}

################################################################################
# IAM Role for EC2 to access this bucket (optional)
################################################################################

resource "aws_iam_role" "ec2_s3_role" {
  count = var.create_iam_resources ? 1 : 0

  name = "${var.owner}-${var.project_name}-${var.aws_region}-ec2-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })

  tags = {
    Owner   = var.owner
    Project = var.project_name
    Region  = var.aws_region
  }
}

resource "aws_iam_role_policy" "ec2_s3_inline" {
  count = var.create_iam_resources ? 1 : 0

  name = "${var.owner}-${var.project_name}-${var.aws_region}-s3-inline"
  role = aws_iam_role.ec2_s3_role[0].id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "BucketList",
        Effect   = "Allow",
        Action   = ["s3:ListBucket","s3:ListBucketMultipartUploads"],
        Resource = aws_s3_bucket.molt_bucket.arn
      },
      {
        Sid      = "ObjectReadWrite",
        Effect   = "Allow",
        Action   = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:AbortMultipartUpload",
          "s3:PutObjectTagging"
        ],
        Resource = "${aws_s3_bucket.molt_bucket.arn}/*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  count = var.create_iam_resources ? 1 : 0

  name = "${var.owner}-${var.project_name}-${var.aws_region}-instance-profile"
  role = aws_iam_role.ec2_s3_role[0].name
}

