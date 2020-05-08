# -----------------------------------------------------------------------------
# s3 dropbox bucket
# -----------------------------------------------------------------------------
resource "aws_s3_bucket" "dropbox" {
  bucket_prefix = var.base_name
  acl           = "private"
  region        = var.aws_region

  # be very cautious about using this in a production environment
  force_destroy = true

  lifecycle_rule {
    enabled = true

    expiration {
      days = 7
    }
  }

  tags = merge({ "Name" = "dropbox" }, var.tags)
}

resource "aws_s3_account_public_access_block" "dropbox" {
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# -----------------------------------------------------------------------------
# s3 thumbnails bucket
# -----------------------------------------------------------------------------
resource "aws_s3_bucket" "thumbnails" {
  bucket_prefix = var.base_name
  acl           = "private"
  region        = var.aws_region

  # be very cautious about using this in a production environment
  force_destroy = true

  tags = merge({ "Name" = "thumbnails" }, var.tags)
}

resource "aws_s3_account_public_access_block" "thumbnails" {
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
