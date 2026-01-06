variable "elastic_ips" {
  description = "Map of Elastic IP configurations"
  type = map(object({
    domain = string
    tags   = map(string)
  }))
}

/* Elastic IP for NAT */
module "elastic_ip" {
  for_each = var.elastic_ips

  source = "github.com/davidshare/terraform-aws-modules//elastic_ip?ref=elastic_ip-v1.0.0"

  domain = each.value.domain
  tags   = merge(each.value.tags, local.tags)

  depends_on = [module.internet_gateway]
}