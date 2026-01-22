# ====================================
# Auto Scaling Variables
# ====================================

variable "scaling_targets" {
  description = "Map of Application Auto Scaling targets"
  type = map(object({
    min_capacity       = number
    max_capacity       = number
    service_namespace  = string
    resource_id        = string
    scalable_dimension = string
    tags               = map(string)
  }))
}

variable "scaling_policies" {
  description = "Map of Application Auto Scaling policies"
  type = map(object({
    name                   = string
    service_namespace      = string
    resource_id            = string
    scalable_dimension     = string
    target_value           = number
    predefined_metric_type = string
    resource_label         = optional(string)
    scale_in_cooldown      = optional(number)
    scale_out_cooldown     = optional(number)
    disable_scale_in       = optional(bool)
  }))
}

# ====================================
# Auto Scaling Target
# ====================================
module "scaling_target" {
  for_each = var.scaling_targets

  # source = "github.com/davidshare/terraform-aws-modules//appautoscaling_target?ref=appautoscaling_target-v1.0.0"
  source = "/media/davidshare/Tersu/TersuCorp/devopsforge/projects/terraform-aws-modules/appautoscaling_target"

  min_capacity       = each.value.min_capacity
  max_capacity       = each.value.max_capacity
  service_namespace  = each.value.service_namespace
  resource_id        = each.value.resource_id
  scalable_dimension = each.value.scalable_dimension
  tags               = merge(each.value.tags, local.tags)
}

# ====================================
# Auto Scaling Policy (Target Tracking)
# ====================================
module "scaling_policy" {
  for_each = var.scaling_policies

  # source = "github.com/davidshare/terraform-aws-modules//appautoscaling_policy?ref=appautoscaling_policy-v1.0.0"
  source = "/media/davidshare/Tersu/TersuCorp/devopsforge/projects/terraform-aws-modules/appautoscaling_policy"

  name               = each.value.name
  service_namespace  = each.value.service_namespace
  resource_id        = each.value.resource_id
  scalable_dimension = each.value.scalable_dimension
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration = {
    target_value       = each.value.target_value
    disable_scale_in   = each.value.disable_scale_in
    scale_in_cooldown  = each.value.scale_in_cooldown
    scale_out_cooldown = each.value.scale_out_cooldown

    predefined_metric_specification = {
      predefined_metric_type = each.value.predefined_metric_type
      # Format: <load-balancer-arn-suffix>/<target-group-arn-suffix>
      resource_label = "${module.alb.backend.arn_suffix}/${module.target_group.backend_api.arn_suffix}"
    }
  }
}