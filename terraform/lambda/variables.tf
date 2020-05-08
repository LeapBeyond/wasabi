# -----------------------------------------------------------------------------
# injected parameters
# -----------------------------------------------------------------------------
variable aws_account {
  description = "aws account the assets are created in"
  type        = string
}

variable aws_region {
  description = "region the assets are created in"
  type        = string
}

variable thumbnail_bucket {
  description = "id of the thumbnail bucket"
  type        = string
}

variable dropbox_arn {
  description = "arn of the dropbox bucket"
  type        = string
}

variable dropbox_bucket {
  description = "id of the dropbox bucket"
  type        = string
}

variable wasabi_region {
  description = "region that the wasabi bucket lives in"
  type        = string
}

variable wasabi_secret {
  description = "name of the secretsmanager secret with wasabi credentials"
  type        = string
  default     = "demo/wasabi/access"
}

variable wasabi_bucket {
  description = "name of the archive bucket in wasabi"
  type        = string
}

variable tags {
  description = "base tags to apply to assets"
  type        = map
}
