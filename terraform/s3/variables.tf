# -----------------------------------------------------------------------------
# things that may not change
# -----------------------------------------------------------------------------

variable "base_name" {
  description = "prefix used for most assets"
  type        = string
  default     = "photos"
}

# -----------------------------------------------------------------------------
# injected parameters
# -----------------------------------------------------------------------------

variable "aws_region" {
  description = "aws region to create assets in"
  type        = string
}

variable "aws_profile" {
  description = "aws profile used to create assets with"
  type        = string
}

variable "tags" {
  description = "base tags to apply to assets"
  type        = map
}