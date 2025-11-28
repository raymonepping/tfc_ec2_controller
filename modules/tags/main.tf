locals {
  base_tags = {
    Environment = var.environment
    CostCenter  = var.cost_center
    Application = var.application
    Owner       = var.owner
    Terraform   = "true"
  }

  effective_tags = merge(
    local.base_tags,
    var.extra_tags
  )
}

output "effective_tags" {
  description = "Final tag map used by all other modules"
  value       = local.effective_tags
}
