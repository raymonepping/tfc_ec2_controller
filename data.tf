##############################################################################
# Data sources
#
# This file keeps all shared lookups together.
# For this demo:
#   - We resolve a RHEL 10 AMI from the Red Hat publisher account
#   - We pin architecture and root device characteristics so it matches
#     the lifecycle precondition in the compute module
##############################################################################

##############################################################################
# AMI lookup is handled by the ami module.
# It uses official Red Hat images and respects architecture.
##############################################################################
