variable "vpcs" {
  description = "Map of VPCs with their configuration"
  type = map(object({
    cidr_block                       = string
    enable_dns_hostnames             = bool
    assign_generated_ipv6_cidr_block = bool
    tags                             = map(string)
  }))
}


module "vpc" {
  for_each = var.vpcs

  source = "github.com/davidshare/terraform-aws-modules//vpc?ref=vpc-v1.0.0"

  cidr_block                       = each.value.cidr_block
  enable_dns_hostnames             = each.value.enable_dns_hostnames
  assign_generated_ipv6_cidr_block = each.value.assign_generated_ipv6_cidr_block

  tags = merge(each.value.tags, local.tags)
}