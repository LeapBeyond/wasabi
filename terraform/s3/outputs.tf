output "dropbox" {
  value = aws_s3_bucket.dropbox.id
}

output "thumbnails" {
  value = aws_s3_bucket.thumbnails.id
}
