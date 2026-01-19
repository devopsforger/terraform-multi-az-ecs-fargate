variable "ecr_repositories" {
  description = "Map of ECR repositories to create"
  type = map(object({
    name                 = string
    image_tag_mutability = string
    image_scanning_configuration = object({
      scan_on_push = bool
    })
    tags = map(string)
  }))
  default = {}
}

variable "ecr_repository_policies" {
  description = "Map of ECR repository policies to apply"
  type = map(object({
    repository = string
    statements = list(object({
      sid    = string
      effect = string
      principals = list(object({
        type        = string
        identifiers = list(string)
      }))
      actions = list(string)
    }))
  }))
  default = {}
}

# ====================================
# ECR Repositories
# ====================================
module "ecr_repository" {
  for_each = var.ecr_repositories

  source                       = "github.com/davidshare/terraform-aws-modules//ecr_repository?ref=ecr_repository-v1.0.0"
  name                         = each.value.name
  image_tag_mutability         = each.value.image_tag_mutability
  image_scanning_configuration = each.value.image_scanning_configuration
  tags                         = merge(each.value.tags, local.tags)
}

# ====================================
# ECR Repository Policies
# ====================================
module "ecr_repository_policy" {
  for_each = var.ecr_repository_policies

  source     = "github.com/davidshare/terraform-aws-modules//ecr_repository_policy?ref=ecr_repository_policy-v1.0.0"
  repository = each.value.repository
  statements = each.value.statements
}
