##############################################################################
# Backend configuration
#
# For this demo, Terraform state is stored locally in a file called
# "terraform.tfstate" in the current working directory.
#
# This keeps everything self-contained on your machine.
#
# For team usage or long-lived environments you would typically:
#   - Switch to the HCP Terraform backend, or
#   - Use another remote backend (for example S3 + DynamoDB for state locking)
#
# Important:
#   - Never commit terraform.tfstate to Git
#   - Treat state as sensitive, since it can contain credentials or secrets
##############################################################################

# terraform {
#  backend "local" {
#    path = "terraform.tfstate"
#  }
#}

terraform {
  cloud {
    organization = "optimus_prime"

    workspaces {
      name = "tfc_ec2_controller"
    }
  }
}
