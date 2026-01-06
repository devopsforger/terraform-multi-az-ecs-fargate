variable "subnets" {
  description = "Map of subnets with their configuration"
  type = map(object({
    cidr_block        = string
    availability_zone = string
    public            = bool
    vpc_name          = string
    tags              = map(string)
  }))
}

# Module call for subnets
module "subnets" {
  for_each = var.subnets

  source = "github.com/davidshare/terraform-aws-modules//subnet?ref=subnet-v1.0.0"

  vpc_id                  = module.vpc[each.value.vpc_name].id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = each.value.public
  tags                    = merge(each.value.tags, local.tags)
}