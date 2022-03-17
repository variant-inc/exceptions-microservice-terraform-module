module "tags" {
  source = "github.com/variant-inc/lazy-terraform//submodules/tags?ref=v1"

  user_tags = {
    team    = var.team
    purpose = var.project_name
    owner   = var.owner
  }

  octopus_tags = var.octopus_tags
  name         = "Tags"
} 