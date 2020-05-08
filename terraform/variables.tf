# -----------------------------------------------------------------------------
# items not likely to change much
# -----------------------------------------------------------------------------

variable tags {
  type = map
  default = {
    "Owner"   = "Leap Beyond"
    "Project" = "Wasabi"
    "Client"  = "Demonstration"
  }
}

# -----------------------------------------------------------------------------
# items that may change
# -----------------------------------------------------------------------------
variable access_ip {
  type    = list
  default = ["0.0.0.0/0"]
}

# -----------------------------------------------------------------------------
# variables to inject via terraform.tfvars
# -----------------------------------------------------------------------------

variable aws_region {
  description = "aws region to create assets in"
  type        = string
}

variable aws_profile {
  description = "aws profile used to create assets with"
  type        = string
}

variable aws_account {
  description = "aws account the assets are created in"
  type        = string
}

variable wasabi_profile {
  description = "name of the wasabi profile being used"
  type        = string
}

variable wasabi_region {
  description = "region that the wasabi bucket lives in"
  type        = string
}

variable wasabi_bucket {
  description = "name of the wasabi bucket"
  type        = string
}
