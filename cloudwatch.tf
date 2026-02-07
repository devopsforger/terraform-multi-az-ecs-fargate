variable "cloudwatch_log_groups" {
  description = "Map of CloudWatch log groups to create"
  type = map(object({
    name              = string
    retention_in_days = number
    kms_key_id        = string
  }))
  default = {}
}

module "cloudwatch_log_group" {
  for_each = var.cloudwatch_log_groups

  source = "/media/davidshare/Tersu/TersuCorp/devopsforge/projects/terraform-aws-modules/cloudwatch_log_group"

  name              = each.value.name
  retention_in_days = each.value.retention_in_days
  kms_key_id        = module.kms_key[each.value.kms_key_id].arn

  tags = local.tags
}
