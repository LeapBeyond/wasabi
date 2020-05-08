# -----------------------------------------------------------------------------
# role that allows lambda to read and write to s3
# -----------------------------------------------------------------------------

data aws_iam_policy_document lambda_assume_role_policy {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data aws_iam_policy_document s3_delete {
  statement {
    actions = ["s3:DeleteObject"]

    resources = [
      format("%s/photos/*", var.dropbox_arn)
    ]
  }
}

data aws_secretsmanager_secret wasabi_secret {
  name = var.wasabi_secret
}

data aws_iam_policy_document read_secret {
  statement {
    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds"
    ]

    resources = [
      data.aws_secretsmanager_secret.wasabi_secret.arn
    ]
  }
}

resource aws_iam_policy lambda_s3_delete {
  name        = "photos-delete"
  description = "allows deletion of the the original photo file"
  policy      = data.aws_iam_policy_document.s3_delete.json
}

resource aws_iam_policy wasabi_secret {
  name        = "wasabi-secret"
  description = "allows read of wasabi credentials secret"
  policy      = data.aws_iam_policy_document.read_secret.json
}

resource aws_iam_role lambda_s3 {
  name                  = "lambda-s3-role"
  assume_role_policy    = data.aws_iam_policy_document.lambda_assume_role_policy.json
  force_detach_policies = true
  tags                  = merge({ "Name" = "lambda-s3-role" }, var.tags)
}

resource aws_iam_role_policy_attachment lambda_s3_execute {
  role       = aws_iam_role.lambda_s3.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLambdaExecute"
}

resource aws_iam_role_policy_attachment lambda_s3_delete {
  role       = aws_iam_role.lambda_s3.name
  policy_arn = aws_iam_policy.lambda_s3_delete.arn
}

resource aws_iam_role_policy_attachment lambda_read_secret {
  role       = aws_iam_role.lambda_s3.name
  policy_arn = aws_iam_policy.wasabi_secret.arn
}
