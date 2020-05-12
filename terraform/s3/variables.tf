# -----------------------------------------------------------------------------
# things that may not change
# -----------------------------------------------------------------------------

variable base_name {
  description = "prefix used for most assets"
  type        = string
  default     = "photos"
}

variable thumb_name {
  description = "prefix used for most thumbnail assets"
  type        = string
  default     = "thumbs"
}

# -----------------------------------------------------------------------------
# injected parameters
# -----------------------------------------------------------------------------

variable aws_region {
  description = "aws region to create assets in"
  type        = string
}

variable tags {
  description = "base tags to apply to assets"
  type        = map
}
