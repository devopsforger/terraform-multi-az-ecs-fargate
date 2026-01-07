# ====================================
# Security Groups (base only - no rules)
# ====================================

variable "security_groups" {
  description = "Map of security groups to create (base security group only, rules managed separately)"
  type = map(object({
    vpc_key     = string # Key to reference the VPC module (e.g., "main")
    name        = string # Required: name of the security group
    description = string # Required: description of the security group
    tags        = optional(map(string), {})
  }))
  default = {}
}

variable "security_group_ingress_rules" {
  description = "Map of ingress rules for security groups"
  type = map(object({
    security_group_key           = string # Key from security_groups map (e.g., "vpc_endpoint_sg")
    description                  = optional(string)
    ip_protocol                  = string
    from_port                    = optional(number)
    to_port                      = optional(number)
    cidr_ipv4                    = optional(string)
    cidr_ipv6                    = optional(string)
    prefix_list_id               = optional(string)
    referenced_security_group_id = optional(string)
    tags                         = optional(map(string), {})
  }))
  default = {}
}

variable "security_group_egress_rules" {
  description = "Map of egress rules for security groups"
  type = map(object({
    security_group_key           = string
    description                  = optional(string)
    ip_protocol                  = string
    from_port                    = optional(number)
    to_port                      = optional(number)
    cidr_ipv4                    = optional(string)
    cidr_ipv6                    = optional(string)
    prefix_list_id               = optional(string)
    referenced_security_group_id = optional(string)
    tags                         = optional(map(string), {})
  }))
  default = {}
}

module "sg" {
  for_each = var.security_groups

  source = "github.com/davidshare/terraform-aws-modules//security_group?ref=security_group-v1.0.0"

  name        = each.value.name
  description = each.value.description
  vpc_id      = module.vpc[each.value.vpc_key].id
  tags = merge(
    {
      Name = each.value.name
    },
    each.value.tags,
    local.tags
  )

  # name_prefix and revoke_rules_on_delete use defaults from your module
}


# ====================================
# Ingress and Egress Rules for VPC Endpoint Security Group
# ====================================

# Ingress rules
module "sg_ingress_rule" {
  for_each = var.security_group_ingress_rules

  source = "github.com/davidshare/terraform-aws-modules//vpc_security_group_ingress_rule?ref=vpc_security_group_ingress_rule-v1.0.0"

  security_group_id            = module.sg[each.value.security_group_key].id
  description                  = each.value.description
  ip_protocol                  = each.value.ip_protocol
  from_port                    = each.value.from_port
  to_port                      = each.value.to_port
  cidr_ipv4                    = each.value.cidr_ipv4
  cidr_ipv6                    = each.value.cidr_ipv6
  prefix_list_id               = each.value.prefix_list_id
  referenced_security_group_id = each.value.referenced_security_group_id

  tags = merge(
    {
      Name = "ingress-${each.key}"
    },
    each.value.tags,
    local.tags
  )
}

# Egress rules
module "sg_egress_rule" {
  for_each = var.security_group_egress_rules

  source = "github.com/davidshare/terraform-aws-modules//vpc_security_group_egress_rule?ref=vpc_security_group_egress_rule-v1.0.0"

  security_group_id            = module.sg[each.value.security_group_key].id
  description                  = each.value.description
  ip_protocol                  = each.value.ip_protocol
  from_port                    = each.value.from_port
  to_port                      = each.value.to_port
  cidr_ipv4                    = each.value.cidr_ipv4
  cidr_ipv6                    = each.value.cidr_ipv6
  prefix_list_id               = each.value.prefix_list_id
  referenced_security_group_id = each.value.referenced_security_group_id

  tags = merge(
    {
      Name = "egress-${each.key}"
    },
    each.value.tags,
    local.tags
  )
}