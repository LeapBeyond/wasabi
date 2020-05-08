output dropbox {
  value = aws_s3_bucket.dropbox.id
}

output dropbox_arn {
  value = aws_s3_bucket.dropbox.arn
}

output thumbnails {
  value = aws_s3_bucket.thumbnails.id
}
