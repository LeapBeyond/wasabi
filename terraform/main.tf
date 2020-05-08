# -----------------------------------------------------------------------------
# module to create s3 buckets
# -----------------------------------------------------------------------------

module "s3" {
  source = "./s3"

  aws_region     = var.aws_region
  tags           = var.tags
}