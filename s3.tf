locals {
  s3_policy_statements = {
    for k, v in var.s3_policy_documents :
    k => [
      for stmt in v.statements : {
        sid       = lookup(stmt, "sid", null)
        effect    = stmt.effect
        actions   = stmt.actions
        resources = ["${module.s3_bucket[v.bucket_key].arn}/*"]

        # Preserve from .tfvars — do NOT force empty
        principals         = lookup(stmt, "principals", [])
        not_actions        = lookup(stmt, "not_actions", [])
        not_resources      = lookup(stmt, "not_resources", [])
        condition_test     = lookup(stmt, "condition_test", null)
        condition_variable = lookup(stmt, "condition_variable", null)
        condition_values   = lookup(stmt, "condition_values", null)
      }
    ]
  }
}

# ====================================
# Frontend Variables
# ====================================

variable "s3_buckets" {
  description = "Map of S3 buckets for static hosting"
  type = map(object({
    bucket_prefix = optional(string)
    force_destroy = bool
    tags          = map(string)
    server_side_encryption_rules = list(object({
      apply_server_side_encryption_by_default = object({
        sse_algorithm     = string
        kms_master_key_id = optional(string)
      })
    }))
    versioning_configuration = optional(object({
      status     = string           # Enabled | Disabled | Suspended
      mfa_delete = optional(string) # Enabled | Disabled
    }))
  }))
}

variable "s3_bucket_website_configs" {
  description = "Map of S3 bucket website configurations"
  type = map(object({
    bucket_key = string
    index_document = object({
      suffix = string
    })
    error_document = optional(object({
      key = string
    }))
    redirect_all_requests_to = optional(object({
      host_name = string
      protocol  = optional(string)
    }))
    routing_rules = optional(list(object({
      condition = optional(object({
        http_error_code_returned_equals = optional(string)
        key_prefix_equals               = optional(string)
      }))
      redirect = object({
        host_name               = optional(string)
        protocol                = optional(string)
        replace_key_prefix_with = optional(string)
        replace_key_with        = optional(string)
        http_redirect_code      = optional(string)
      })
    })))
  }))
}


variable "s3_policy_documents" {
  description = "Policy documents for S3 buckets"
  type = map(object({
    bucket_key = string
    statements = list(object({
      sid     = optional(string)
      effect  = string
      actions = list(string)

      resources = optional(list(string), [])
    }))
  }))
  default = {}
}


variable "s3_bucket_policies" {
  description = "Map of S3 bucket policies"
  type = map(object({
    bucket_key = string
    policy     = string
  }))
  default = {}
}

variable "s3_bucket_public_access_blocks" {
  description = "Map of S3 bucket public access block configurations"
  type = map(object({
    block_public_acls       = bool
    block_public_policy     = bool
    ignore_public_acls      = bool
    restrict_public_buckets = bool
  }))
  default = {}
}

# ====================================
# S3 Bucket
# ====================================
module "s3_bucket" {
  for_each = var.s3_buckets

  # source = "github.com/davidshare/terraform-aws-modules//s3_bucket?ref=s3_bucket-v1.0.0"
  source = "/media/davidshare/Tersu/TersuCorp/devopsforge/projects/terraform-aws-modules/s3_bucket"

  bucket_prefix = each.value.bucket_prefix
  force_destroy = each.value.force_destroy
  tags          = merge(each.value.tags, local.tags)
}

# ====================================
# S3 Bucket Ownership Controls
# ====================================
module "s3_bucket_ownership_controls" {
  for_each = var.s3_buckets

  # source = "github.com/davidshare/terraform-aws-modules//s3_bucket_ownership_controls?ref=s3_bucket_ownership_controls-v1.0.0"
  source = "/media/davidshare/Tersu/TersuCorp/devopsforge/projects/terraform-aws-modules/s3_bucket_ownership_controls"

  bucket           = module.s3_bucket[each.key].arn
  object_ownership = "BucketOwnerEnforced"
}

# ====================================
# S3 Bucket Public Access Block
# ====================================
module "s3_bucket_public_access_block" {
  for_each = var.s3_bucket_public_access_blocks

  # source = "github.com/davidshare/terraform-aws-modules//s3_bucket_public_access_block?ref=s3_bucket_public_access_block-v1.0.0"
  source = "/media/davidshare/Tersu/TersuCorp/devopsforge/projects/terraform-aws-modules/s3_bucket_public_access_block"

  bucket = module.s3_bucket[each.key].arn

  block_public_acls       = each.value.block_public_acls
  block_public_policy     = each.value.block_public_policy
  ignore_public_acls      = each.value.ignore_public_acls
  restrict_public_buckets = each.value.restrict_public_buckets
}

# ====================================
# S3 Bucket Website Configuration
# ====================================
module "s3_bucket_website_configuration" {
  for_each = var.s3_bucket_website_configs

  # source = "github.com/davidshare/terraform-aws-modules//s3_bucket_website_configuration?ref=s3_bucket_website_configuration-v1.0.0"
  source = "/media/davidshare/Tersu/TersuCorp/devopsforge/projects/terraform-aws-modules/s3_bucket_website_configuration"

  bucket                   = module.s3_bucket[each.value.bucket_key].arn
  index_document           = each.value.index_document
  error_document           = each.value.error_document
  redirect_all_requests_to = each.value.redirect_all_requests_to
  routing_rules            = each.value.routing_rules != null ? jsonencode(each.value.routing_rules) : null
}

# ====================================
# S3 Bucket Policy
# ====================================
module "iam_policy_document_s3" {
  for_each = local.s3_policy_statements

  source = "/media/davidshare/Tersu/TersuCorp/devopsforge/projects/terraform-aws-modules/iam_policy_document"

  statements = each.value
}


module "s3_bucket_policy" {
  for_each = module.iam_policy_document_s3

  # source = "github.com/davidshare/terraform-aws-modules//s3_bucket_policy?ref=s3_bucket_policy-v1.0.0"
  source = "/media/davidshare/Tersu/TersuCorp/devopsforge/projects/terraform-aws-modules/s3_bucket_policy"

  bucket = module.s3_bucket[var.s3_policy_documents[each.key].bucket_key].arn
  policy = each.value.policy_json
}

# ====================================
# S3 Bucket Versioning
# ====================================
module "s3_bucket_versioning" {
  for_each = var.s3_buckets

  # source = "github.com/davidshare/terraform-aws-modules//s3_bucket_versioning?ref=s3_bucket_versioning-v1.0.0"
  source = "/media/davidshare/Tersu/TersuCorp/devopsforge/projects/terraform-aws-modules/s3_bucket_versioning"

  bucket = module.s3_bucket[each.key].arn
  versioning_configuration = each.value.versioning_configuration != null ? each.value.versioning_configuration : {
    status = "Enabled"
  }
}

# ====================================
# S3 Bucket Server Side Encryption
# ====================================
module "s3_bucket_server_side_encryption_configuration" {
  for_each = var.s3_buckets

  # source = "github.com/davidshare/terraform-aws-modules//s3_bucket_server_side_encryption_configuration?ref=s3_bucket_server_side_encryption_configuration-v1.0.0"
  source = "/media/davidshare/Tersu/TersuCorp/devopsforge/projects/terraform-aws-modules/s3_bucket_server_side_encryption_configuration"

  bucket = module.s3_bucket[each.key].arn
  rules  = each.value.server_side_encryption_rules
}