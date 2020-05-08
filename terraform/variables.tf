# -----------------------------------------------------------------------------
# items not likely to change much
# -----------------------------------------------------------------------------

variable "tags" {
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
variable "access_ip" {
  type    = list
  default = ["0.0.0.0/0"]
}

# -----------------------------------------------------------------------------
# variables to inject via terraform.tfvars
# -----------------------------------------------------------------------------

variable "aws_region" {
  description = "aws region to create assets in"
  type        = string
}

variable "aws_profile" {
  description = "aws profile used to create assets with"
  type        = string
}
