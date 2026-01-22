variable "ecs_clusters" {
  type = map(object({
    name = string
    tags = map(string)
  }))
}

variable "ecs_task_definitions" {
  type = map(object({
    family                   = string
    requires_compatibilities = list(string)
    network_mode             = string
    cpu                      = number
    memory                   = number
    execution_role_arn       = string
    task_role_arn            = string
    container_definitions    = any
    tags                     = map(string)
  }))
}

variable "ecs_services" {
  type = map(object({
    name             = string
    cluster_key      = string
    task_def_key     = string
    desired_count    = number
    launch_type      = string
    platform_version = string
    assign_public_ip = bool
    subnets          = list(string)
    security_groups  = list(string)
    target_group_arn = string
    container_name   = string
    container_port   = number
    tags             = map(string)
  }))
}


module "ecs_cluster" {
  for_each = var.ecs_clusters

  source = "github.com/davidshare/terraform-aws-modules//ecs_cluster?ref=ecs_cluster-v1.0.0"

  name = each.value.name
  tags = merge(each.value.tags, local.tags)
}


module "ecs_task_definition" {
  for_each = var.ecs_task_definitions

  source = "github.com/davidshare/terraform-aws-modules//ecs_task_definition?ref=ecs_task_definition-v1.0.0"

  family                   = each.value.family
  requires_compatibilities = each.value.requires_compatibilities
  network_mode             = each.value.network_mode
  cpu                      = each.value.cpu
  memory                   = each.value.memory
  execution_role_arn       = each.value.execution_role_arn
  task_role_arn            = each.value.task_role_arn
  container_definitions    = jsonencode(each.value.container_definitions)

  tags = merge(each.value.tags, local.tags)
}

module "ecs_service" {
  for_each = var.ecs_services

  source = "github.com/davidshare/terraform-aws-modules//ecs_service?ref=ecs_service-v1.0.0"


  name            = each.value.name
  cluster         = module.ecs_cluster[each.value.cluster_key].arn
  task_definition = module.ecs_task_definition[each.value.task_def_key].arn

  desired_count    = each.value.desired_count
  launch_type      = each.value.launch_type
  platform_version = each.value.platform_version

  network_configuration = {
    assign_public_ip = each.value.assign_public_ip
    subnets = [
      for subnet_key in each.value.subnets :
      module.subnets[subnet_key].id
    ]
    security_groups = [
      for sg_key in each.value.security_groups :
      module.security_groups[sg_key].id
    ]
  }

  depends_on = [
    module.iam_role_policy_attachment
  ]

  tags = merge(each.value.tags, local.tags)
}
