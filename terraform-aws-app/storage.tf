################################################################################
# terraform-aws/s3.tf
#
# Each region’s S3 bucket and IAM role/profile must include aws_region
# so names are unique per region.
################################################################################

locals {
  # Now include the region (aws_region) to avoid collisions
  bucket_name = "${var.owner}-${var.project_name}-${var.aws_region}-molt-bucket"
}

resource "aws_s3_bucket" "molt_bucket" {
  bucket        = local.bucket_name
  force_destroy = true

  tags = {
    Name = local.bucket_name
  }
}

# Create an empty “incoming/” prefix to simulate a directory
resource "aws_s3_object" "incoming_directory" {
  bucket  = aws_s3_bucket.molt_bucket.id
  key     = "incoming/"   # trailing slash simulates a directory
  content = ""
}

resource "aws_s3_bucket_policy" "molt_bucket_policy" {
  bucket = aws_s3_bucket.molt_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowReadWriteFromMyIP",
        Effect    = "Allow",
        Principal = "*",
        Action    = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        Resource = [
          aws_s3_bucket.molt_bucket.arn,
          "${aws_s3_bucket.molt_bucket.arn}/*"
        ],
        Condition = {
          IpAddress = {
            "aws:SourceIp": [
              var.my_ip_address,
              var.cidr
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_role" "ec2_s3_role" {
  name = "${var.owner}-${var.project_name}-${var.aws_region}-ec2-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "s3_policy" {
  name = "${var.owner}-${var.project_name}-${var.aws_region}-s3-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      Resource = [
        aws_s3_bucket.molt_bucket.arn,
        "${aws_s3_bucket.molt_bucket.arn}/*"
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_s3_attachment" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = aws_iam_policy.s3_policy.arn
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.owner}-${var.project_name}-${var.aws_region}-instance-profile"
  role = aws_iam_role.ec2_s3_role.name
}
# Role that CRDB will assume to write to your bucket
resource "aws_iam_role" "crdb_changefeed_role" {
  name = "${var.owner}-${var.project_name}-${var.aws_region}-crdb-changefeed-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Action    = "sts:AssumeRole",
      Principal = {
        AWS = "arn:aws:iam::028856232579:role/crdb-wi-b923326b961d-us-east-2"
      }
    }]
  })
}

# Policy granting write to your bucket/prefix
resource "aws_iam_policy" "crdb_changefeed_s3" {
  name = "${var.owner}-${var.project_name}-${var.aws_region}-crdb-changefeed-s3"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "ListBucket",
        Effect = "Allow",
        Action = ["s3:ListBucket", "s3:ListBucketMultipartUploads"],
        Resource = aws_s3_bucket.molt_bucket.arn
      },
      {
        Sid    = "PutObjects",
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:AbortMultipartUpload",
          "s3:PutObjectTagging"
        ],
        Resource = "${aws_s3_bucket.molt_bucket.arn}/*"
      }
      # If bucket uses SSE-KMS, also add kms:Encrypt/GenerateDataKey on the CMK
    ]
  })
}

resource "aws_iam_role_policy_attachment" "crdb_changefeed_attach" {
  role       = aws_iam_role.crdb_changefeed_role.name
  policy_arn = aws_iam_policy.crdb_changefeed_s3.arn
}

