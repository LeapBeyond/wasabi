# -----------------------------------------------------------------------------
# module to create s3 buckets
# -----------------------------------------------------------------------------

module s3 {
  source = "./s3"

  aws_region = var.aws_region
  tags       = var.tags
}

module lambda {
  source = "./lambda"

  aws_account      = var.aws_account
  aws_region       = var.aws_region
  thumbnail_bucket = module.s3.thumbnails
  dropbox_bucket   = module.s3.dropbox
  dropbox_arn      = module.s3.dropbox_arn
  wasabi_region    = var.wasabi_region
  wasabi_bucket    = var.wasabi_bucket
  tags             = var.tags
}
