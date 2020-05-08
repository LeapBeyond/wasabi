# -----------------------------------------------------------------------------
# lambda function that sees files being added to drop box and processes them
# -----------------------------------------------------------------------------
resource aws_lambda_function generate_thumbnails {

  # TODO: move the thumbnail zip into an s3 location
  filename         = "../python/Thumbnail.zip"
  function_name    = "Thumbnail"
  role             = aws_iam_role.lambda_s3.arn
  handler          = "Thumbnail.lambda_handler"
  source_code_hash = filebase64sha256("../python/Thumbnail.zip")
  runtime          = "python3.7"
  timeout          = "60"
  memory_size      = "1024"

  environment {
    variables = {
      THUMBNAIL_BUCKET = var.thumbnail_bucket,
      WASABI_REGION    = var.wasabi_region,
      WASABI_SECRET    = var.wasabi_secret,
      WASABI_BUCKET    = var.wasabi_bucket,
      REGION           = var.aws_region
    }
  }

  tags = merge({ "Name" = "Thumbnail" }, var.tags)
}

# allow S3 to invoke the function under certain circumstances

resource aws_lambda_permission allow_thumbnails {
  statement_id_prefix = "s3invoke"
  action              = "lambda:InvokeFunction"
  function_name       = aws_lambda_function.generate_thumbnails.function_name
  principal           = "s3.amazonaws.com"
  source_arn          = var.dropbox_arn
  source_account      = var.aws_account
}

# set the bucket to issue notifications

resource aws_s3_bucket_notification bucket_notification {
  depends_on = [aws_lambda_permission.allow_thumbnails]
  bucket     = var.dropbox_bucket

  lambda_function {
    lambda_function_arn = aws_lambda_function.generate_thumbnails.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "photos/"
  }
}
