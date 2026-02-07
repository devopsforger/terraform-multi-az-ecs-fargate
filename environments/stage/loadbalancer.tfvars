# ====================================
# Application Load Balancer
# ====================================
load_balancers = {
  backend = {
    name                = "forger-stage-backend-alb"
    internal            = true # Keep it private (only accessible from VPC or API Gateway)
    vpc_key             = "main"
    subnets             = ["backend_private_1", "backend_private_2"]
    security_group_keys = ["backend-app"]
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
    load_balancer_key   = "backend"
    port                = 80
    protocol            = "HTTP"
    default_action_type = "forward"
    target_group_key    = "backend-app"
    tags = {
      Name = "Backend-HTTP-Listener"
    }
  }

  # Uncomment when you have an ACM cert
  # backend_https = {
  #   load_balancer_key   = "backend"
  #   port                = 443
  #   protocol            = "HTTPS"
  #   ssl_policy          = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  #   certificate_arn     = "arn:aws:acm:us-east-1:014208335592:certificate/..."
  #   default_action_type = "forward"
  #   target_group_key    = "backend-app"
  #   tags = {
  #     Name = "Backend-HTTPS-Listener"
  #   }
  # }
}