variable "internet_gateways" {
  description = "Map of internet gateways"
  type = map(object({
    vpc  = string
    tags = map(string)
  }))
}

module "internet_gateway" {
  for_each = var.internet_gateways
  source   = "github.com/davidshare/terraform-aws-modules//internet_gateway?ref=internet_gateway-v1.0.0"

  vpc_id = module.vpc[each.value.vpc].id
  tags   = merge(each.value.tags, local.tags)
}