# ====================================
# Auto Scaling Target for Backend API
# ====================================
scaling_targets = {
  backend_api = {
    min_capacity      = 1
    max_capacity      = 5
    service_namespace = "ecs"
    # Format: service/<cluster-name>/<service-name>
    resource_id        = "service/backend-prod/backend-api"
    scalable_dimension = "ecs:service:DesiredCount"
    tags = {
      Name = "backend-api-scaling-target"
    }
  }
}

# ====================================
# Auto Scaling Policy (ALB Request Count)
# ====================================
scaling_policies = {
  backend_api_request_count = {
    name               = "backend-api-request-count"
    service_namespace  = "ecs"
    resource_id        = "service/backend-prod/backend-api"
    scalable_dimension = "ecs:service:DesiredCount"

    # Scale based on ALB requests per target
    predefined_metric_type = "ALBRequestCountPerTarget"


    target_value       = 1000.0 # 1000 requests per target per minute
    scale_in_cooldown  = 300    # 5 minutes
    scale_out_cooldown = 60     # 1 minute
    disable_scale_in   = false
  }
}