# Variable for route tables
variable "route_tables" {
  description = "Map of route table configurations"
  type = map(object({
    vpc  = string
    tags = map(string)
  }))
}

# Variable for subnet to route table associations
variable "subnets_route_table_association" {
  description = "Map of subnet to route table associations"
  type = map(object({
    subnet      = string
    route_table = string
  }))
}

# Variable for Internet Gateway routes
variable "internet_gateway_routes" {
  description = "Map of routes for Internet Gateway"
  type = map(object({
    route_table = string
    cidr        = string
    gateway     = string
  }))
}

# Variable for NAT Gateway routes
variable "nat_gateway_routes" {
  description = "Map of routes for NAT Gateway"
  type = map(object({
    route_table = string
    cidr        = string
    gateway     = string
  }))
}

# Route tables
module "route_table" {
  for_each = var.route_tables

  source = "github.com/davidshare/terraform-aws-modules//route_table?ref=route_table-v1.0.0"

  vpc_id = module.vpc[each.value.vpc].id
  tags   = merge(each.value.tags, local.tags)
}

# Route table associations
module "subnets_route_table_associations" {
  for_each = var.subnets_route_table_association

  source = "github.com/davidshare/terraform-aws-modules//route_table_association?ref=route_table_association-v1.0.0"

  subnet_id      = module.subnets[each.value.subnet].id
  route_table_id = module.route_table[each.value.route_table].id

  depends_on = [module.subnets, module.route_table]
}

# Routes for Internet Gateway
module "internet_gateway_routes" {
  for_each = var.internet_gateway_routes

  source = "github.com/davidshare/terraform-aws-modules//route?ref=route-v1.0.0"

  route_table_id         = module.route_table[each.value.route_table].id
  destination_cidr_block = each.value.cidr
  gateway_id             = module.internet_gateway[each.value.gateway].id

  depends_on = [module.internet_gateway, module.route_table]
}

# Routes for NAT
module "nat_gateway_routes" {
  for_each = var.nat_gateway_routes

  source = "github.com/davidshare/terraform-aws-modules//route?ref=route-v1.0.0"

  route_table_id         = module.route_table[each.value.route_table].id
  destination_cidr_block = each.value.cidr
  nat_gateway_id         = module.nat_gateway[each.value.gateway].id

  depends_on = [module.nat_gateway, module.route_table]
}