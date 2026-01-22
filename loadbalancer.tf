# ====================================
# Load Balancer Variables
# ====================================

variable "load_balancers" {
  description = "Map of Application Load Balancers"
  type = map(object({
    name     = string
    internal = bool
    vpc_key  = string
    subnets  = list(string)
    tags     = map(string)
  }))
}

variable "target_groups" {
  description = "Map of target groups for load balancers"
  type = map(object({
    name                 = string
    port                 = number
    protocol             = string
    vpc_key              = string
    health_check_path    = optional(string)
    matcher              = optional(string)
    interval             = optional(number)
    timeout              = optional(number)
    healthy_threshold    = optional(number)
    unhealthy_threshold  = optional(number)
    deregistration_delay = optional(number)
    tags                 = map(string)
  }))
}

variable "listeners" {
  description = "Map of listeners for load balancers"
  type = map(object({
    load_balancer_key   = string
    port                = number
    protocol            = string
    ssl_policy          = optional(string)
    certificate_arn     = optional(string)
    default_action_type = string
    target_group_key    = optional(string)
    tags                = map(string)
  }))
}

# ====================================
# ALB Module
# ====================================
module "alb" {
  for_each = var.load_balancers

  source = "github.com/davidshare/terraform-aws-modules//alb?ref=alb-v1.0.0"

  name            = each.value.name
  internal        = each.value.internal
  subnets         = [for k in each.value.subnets : module.subnets[k].id]
  security_groups = [] # Will be auto-created or passed separately

  tags = merge(each.value.tags, local.tags)
}

# ====================================
# Target Group Module
# ====================================
module "target_group" {
  for_each = var.target_groups

  source = "github.com/davidshare/terraform-aws-modules//lb_target_group?ref=lb_target_group-v1.0.0"

  name        = each.value.name
  port        = each.value.port
  protocol    = each.value.protocol
  vpc_id      = module.vpc[each.value.vpc_key].id
  target_type = "ip" # Required for Fargate (tasks use ENI IPs)

  health_check = {
    enabled             = true
    path                = each.value.health_check_path != null ? each.value.health_check_path : "/health"
    port                = each.value.port
    protocol            = each.value.protocol
    interval            = each.value.interval
    timeout             = each.value.timeout
    healthy_threshold   = each.value.healthy_threshold
    unhealthy_threshold = each.value.unhealthy_threshold
    matcher             = each.value.matcher
  }

  deregistration_delay = each.value.deregistration_delay != null ? each.value.deregistration_delay : 300

  tags = merge(each.value.tags, local.tags)
}

# ====================================
# Listener Module
# ====================================
module "listener" {
  for_each = var.listeners

  source = "github.com/davidshare/terraform-aws-modules//lb_listener?ref=lb_listener-v1.0.0"

  load_balancer_arn = module.alb[each.value.load_balancer_key].arn
  port              = each.value.port
  protocol          = each.value.protocol

  ssl_policy      = each.value.ssl_policy
  certificate_arn = each.value.certificate_arn

  default_actions = [{
    type             = each.value.default_action_type
    target_group_arn = each.value.target_group_key != null ? module.target_group[each.value.target_group_key].arn : null
  }]

  tags = merge(each.value.tags, local.tags)
}