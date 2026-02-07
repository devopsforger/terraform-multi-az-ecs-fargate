# ====================================
# Secrets Manager Variables
# ====================================

variable "kms_keys" {
  description = "Map of KMS keys for encryption"
  type = map(object({
    description         = string
    enable_key_rotation = bool
  }))
}

variable "kms_aliases" {
  description = "Map of KMS key aliases"
  type = map(object({
    kms_key_name = string
  }))
}

variable "secrets" {
  description = "Map of Secrets Manager secrets"
  type = map(object({
    description  = string
    kms_key_name = optional(string)
    tags         = map(string)
  }))
}

variable "secret_versions" {
  description = "Map of secret versions with values"
  type = map(object({
    secret_id     = string
    secret_string = string
  }))
}

variable "ssm_parameters" {
  description = "Map of SSM parameters"
  type = map(object({
    name        = string
    description = string
    type        = string # String, StringList, SecureString
    alb_key   = optional(string)
    value       = optional(string)
    key_id      = optional(string) # For SecureString
    tags        = map(string)
  }))
}

# ====================================
# KMS Key
# ====================================
module "kms_key" {
  for_each = var.kms_keys

  # source = "github.com/davidshare/terraform-aws-modules//kms_key?ref=kms_key-v1.0.0"
  source = "/media/davidshare/Tersu/TersuCorp/devopsforge/projects/terraform-aws-modules/kms_key"

  description         = each.value.description
  enable_key_rotation = each.value.enable_key_rotation
}

# ====================================
# KMS Alias
# ====================================
module "kms_alias" {
  for_each = var.kms_aliases

  # source = "github.com/davidshare/terraform-aws-modules//kms_alias?ref=kms_alias-v1.0.0"
  source = "/media/davidshare/Tersu/TersuCorp/devopsforge/projects/terraform-aws-modules/kms_alias"

  name          = each.key
  target_key_id = module.kms_key[each.value.kms_key_name].key_id
}

# ====================================
# Secrets Manager Secret
# ====================================
module "secret" {
  for_each = var.secrets

  source = "github.com/davidshare/terraform-aws-modules//secretsmanager_secret?ref=secretsmanager_secret-v1.0.0"

  name        = each.key
  description = each.value.description
  kms_key_id  = each.value.kms_key_name != null ? module.kms_key[each.value.kms_key_name].arn : null
  tags        = merge(each.value.tags, local.tags)
}

# ====================================
# Secrets Manager Secret Version
# ====================================
module "secret_version" {
  for_each = var.secret_versions

  source = "github.com/davidshare/terraform-aws-modules//secretsmanager_secret_version?ref=secretsmanager_secret_version-v1.0.0"

  secret_id     = each.value.secret_id
  secret_string = each.value.secret_string
}

# ====================================
# SSM Parameter
# ====================================
module "ssm_parameter" {
  for_each = var.ssm_parameters

  # source = "github.com/davidshare/terraform-aws-modules//ssm_parameter?ref=ssm_parameter-v1.0.0"
  source = "/media/davidshare/Tersu/TersuCorp/devopsforge/projects/terraform-aws-modules/ssm_parameter"

  name        = each.value.name
  description = each.value.description
  type        = each.value.type
  value       = each.value.alb_key != null ? module.alb[each.value.alb_key].dns_name : each.value.value
  key_id      = each.value.key_id
  tags        = merge(each.value.tags, local.tags)
}