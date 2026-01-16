# Gateway endpoints (S3)
variable "gateway_endpoints" {
  description = "Map of gateway VPC endpoints (e.g., S3)"
  type = map(object({
    vpc_name         = string
    service_name     = string
    route_table_keys = list(string)
    policy           = string
    tags             = map(string)
  }))
  default = {}
}

# Interface endpoints (PrivateLink)
variable "interface_endpoints" {
  description = "Map of interface VPC endpoints"
  type = map(object({
    vpc_name            = string
    service_name        = string
    subnet_keys         = list(string)
    security_group_keys = list(string)
    private_dns_enabled = bool
    tags                = map(string)
  }))
  default = {}
}

module "gateway_endpoints" {
  for_each = var.gateway_endpoints

  source = "github.com/davidshare/terraform-aws-modules//vpc_endpoint?ref=vpc_endpoint-v1.0.0"

  vpc_id            = module.vpc[each.value.vpc_name].id
  vpc_endpoint_type = "Gateway"
  service_name      = each.value.service_name
  route_table_ids   = [for rt in each.value.route_table_keys : module.route_table[rt].id]
  policy            = each.value.policy
  tags              = merge(each.value.tags, local.tags)
}

# Interface endpoints
module "interface_endpoints" {
  for_each = var.interface_endpoints

  source = "/media/davidshare/Tersu/TersuCorp/TersuLabs/learning/DevOps/terraform-aws-modules/vpc_endpoint/"

  vpc_id              = module.vpc[each.value.vpc_name].id
  vpc_endpoint_type   = "Interface"
  service_name        = each.value.service_name
  subnet_ids          = [for sk in each.value.subnet_keys : module.subnets[sk].id]
  security_group_ids  = [for key in each.value.security_group_keys : module.sg[key].id]
  private_dns_enabled = each.value.private_dns_enabled
  tags                = merge(each.value.tags, local.tags)
}


variable "endpoint_policies" {
  description = "Map of VPC endpoint policies, keyed by the same name used in gateway_endpoints or interface_endpoints (e.g., 's3', 'ecr_api')."
  type = map(object({
    policy = optional(string, null)
  }))
  default = {}
}

locals {
  # Merge IDs from both gateway and interface endpoint modules
  all_vpc_endpoint_ids = merge(
    { for k, m in module.gateway_endpoints : k => m.id },
    { for k, m in module.interface_endpoints : k => m.id }
  )
}

module "vpc_endpoint_policies" {
  for_each = var.endpoint_policies

  source            = "/media/davidshare/Tersu/TersuCorp/TersuLabs/learning/DevOps/terraform-aws-modules/vpc_endpoint_policy/"
  vpc_endpoint_id   = local.all_vpc_endpoint_ids[each.key]
  policy            = each.value.policy
  endpoint_name     = each.key  # Optional but useful for validation messages

  depends_on = [
    module.gateway_endpoints,
    module.interface_endpoints
  ]
}