terraform {
  backend "s3" {
    bucket         = "lbatrain20200428162949619600000001"
    key            = "wasabi"
    region         = "eu-west-2"
    encrypt        = true
    kms_key_id     = "arn:aws:kms:eu-west-2:422515236307:key/dbb95ea0-24e8-41dc-9ce8-279741fac2ad"
    dynamodb_table = "terraform-state-lock"
    profile        = "lba_train"
  }
}
