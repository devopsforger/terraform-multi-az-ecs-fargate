# ====================================
# Auto Scaling Target for Backend API
# ====================================
scaling_targets = {
  backend-app = {
    min_capacity       = 1
    max_capacity       = 5
    service_namespace  = "ecs"
    ecs_service_key    = "backend-app"
    scalable_dimension = "ecs:service:DesiredCount"
    tags = {
      Name = "backend-app-scaling-target"
    }
  }
}

# ====================================
# Auto Scaling Policy (ALB Request Count)
# ====================================
scaling_policies = {
  backend-app_request_count = {
    name               = "backend-app-request-count"
    ecs_service_key    = "backend-app"
    service_namespace  = "ecs"
    scalable_dimension = "ecs:service:DesiredCount"

    # Scale based on ALB requests per target
    predefined_metric_type = "ALBRequestCountPerTarget"


    target_value       = 1000.0 # 1000 requests per target per minute
    scale_in_cooldown  = 300    # 5 minutes
    scale_out_cooldown = 60     # 1 minute
    disable_scale_in   = false
    resource_label     = "backend"
    target_group_key   = "backend-app"
  }
}