# ====================================
# Database Variables
# ====================================

variable "db_subnet_groups" {
  description = "Map of DB subnet groups"
  type = map(object({
    subnet_keys = list(string)
    tags        = map(string)
  }))
}

variable "db_parameter_groups" {
  description = "Map of DB parameter groups"
  type = map(object({
    family      = string
    description = string
    parameters = list(object({ # 👈 CHANGED FROM map(string)
      name         = string
      value        = string
      apply_method = optional(string)
    }))
    tags = map(string)
  }))
}

variable "db_instances" {
  description = "Map of RDS instances"
  type = map(object({
    identifier                  = string
    engine                      = string
    engine_version              = string
    instance_class              = string
    allocated_storage           = number
    max_allocated_storage       = optional(number)
    db_subnet_group_key         = string
    db_parameter_group_key      = optional(string)
    db_option_group_key         = optional(string)
    vpc_security_group_keys     = list(string)
    multi_az                    = bool
    publicly_accessible         = bool
    username                    = string
    password                    = optional(string)
    password_secret_key         = optional(string) # Key in secret_versions map for DB password
    manage_master_user_password = optional(bool)
    backup_retention_period     = number
    skip_final_snapshot         = bool
    deletion_protection         = bool
    tags                        = map(string)
  }))
}

# ====================================
# DB Subnet Group
# ====================================
module "db_subnet_group" {
  for_each = var.db_subnet_groups

  source = "github.com/davidshare/terraform-aws-modules//db_subnet_group?ref=db_subnet_group-v1.0.0"

  name       = each.key
  subnet_ids = [for k in each.value.subnet_keys : module.subnets[k].id]
  tags       = merge(each.value.tags, local.tags)
}

# ====================================
# DB Parameter Group
# ====================================
module "db_parameter_group" {
  for_each = var.db_parameter_groups

  # source = "github.com/davidshare/terraform-aws-modules//db_parameter_group?ref=db_parameter_group-v1.0.0"
  source = "/media/davidshare/Tersu/TersuCorp/devopsforge/projects/terraform-aws-modules/db_parameter_group"

  name        = each.key
  family      = each.value.family
  description = each.value.description
  parameters  = each.value.parameters
  tags        = merge(each.value.tags, local.tags)
}


# ====================================
# DB Instance
# ====================================
module "db_instance" {
  for_each = var.db_instances

  # source = "github.com/davidshare/terraform-aws-modules//db_instance?ref=db_instance-v1.0.0"
  source = "/media/davidshare/Tersu/TersuCorp/devopsforge/projects/terraform-aws-modules/db_instance"

  identifier              = each.value.identifier
  engine                  = each.value.engine
  engine_version          = each.value.engine_version
  instance_class          = each.value.instance_class
  allocated_storage       = each.value.allocated_storage
  max_allocated_storage   = each.value.max_allocated_storage
  db_subnet_group_name    = module.db_subnet_group[each.value.db_subnet_group_key].name
  parameter_group_name    = each.value.db_parameter_group_key != null ? module.db_parameter_group[each.value.db_parameter_group_key].name : null
  vpc_security_group_ids  = [for k in each.value.vpc_security_group_keys : module.security_groups[k].id]
  multi_az                = each.value.multi_az
  publicly_accessible     = each.value.publicly_accessible
  username                = each.value.username
  password                = module.secret_version[each.value.password_secret_key].secret_string
  backup_retention_period = each.value.backup_retention_period
  skip_final_snapshot     = each.value.skip_final_snapshot
  deletion_protection     = each.value.deletion_protection
  tags                    = merge(each.value.tags, local.tags)

  depends_on = [
    module.secret_version,
    module.db_subnet_group,
    module.db_parameter_group
  ]
}