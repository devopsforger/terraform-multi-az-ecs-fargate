# ====================================
# IAM Roles
# ====================================
variable "iam_roles" {
  description = "Map of IAM roles to create"
  type = map(object({
    assume_role_policy = string # JSON string or use templatefile
    tags               = map(string)
  }))
  default = {}
}

module "iam_role" {
  for_each = var.iam_roles

  source = "github.com/davidshare/terraform-aws-modules//iam_role?ref=iam_role-v1.0.0"

  name               = each.key
  assume_role_policy = each.value.assume_role_policy
  tags               = merge(each.value.tags, local.tags)
}


# ====================================
# IAM Policies (managed)
# ====================================
variable "iam_policies" {
  description = "Map of IAM managed policies"
  type = map(object({
    description = string
    policy      = string # JSON policy document
    tags        = map(string)
  }))
  default = {}
}

module "iam_policy" {
  for_each = var.iam_policies

  source = "github.com/davidshare/terraform-aws-modules//iam_policy?ref=iam_policy-v1.0.0"

  name        = each.key
  description = each.value.description
  policy      = each.value.policy
  tags        = merge(each.value.tags, local.tags)
}


# ====================================
# Role-Policy Attachments
# ====================================
variable "iam_role_policy_attachments" {
  description = "Map of role-policy attachments"
  type = map(object({
    role_name  = string
    policy_arn = string
  }))
  default = {}
}

module "iam_role_policy_attachment" {
  for_each = var.iam_role_policy_attachments

  source = "github.com/davidshare/terraform-aws-modules//iam_role_policy_attachment?ref=iam_role_policy_attachment-v1.0.0"

  role       = each.value.role_name
  policy_arn = each.value.policy_arn
}