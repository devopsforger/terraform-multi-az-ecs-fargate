# ====================================
# Application Load Balancer
# ====================================
load_balancers = {
  backend-app = {
    name                = "forger-stage-backend-alb"
    internal            = false
    vpc_key             = "main"
    subnets             = ["nat_public_1", "nat_public_2"]
    security_group_keys = ["backend_alb"]
    tags = {
      Name = "Backend-ALB"
    }
  }
}

# ====================================
# Target Group (for FastAPI)
# ====================================
target_groups = {
  backend-app = {
    name                 = "forger-stage-backend-app-tg"
    port                 = 8000
    protocol             = "HTTP"
    vpc_key              = "main"
    matcher              = "200-299"
    interval             = 30
    timeout              = 5
    healthy_threshold    = 2
    unhealthy_threshold  = 2
    health_check_path    = "/health"
    deregistration_delay = 300
    tags = {
      Name = "backend-app-TG"
    }
  }
}

# ====================================
# Listener (HTTP only for now; add HTTPS later)
# ====================================
listeners = {
  backend_http = {
    load_balancer_key   = "backend-app"
    port                = 80
    protocol            = "HTTP"
    default_action_type = "forward"
    target_group_key    = "backend-app"
    tags = {
      Name = "Backend-HTTP-Listener"
    }
  }
}