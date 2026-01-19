security_groups = {
  vpc_endpoint_sg = {
    vpc_key     = "main"
    name        = "vpce-shared"
    description = "Shared security group for all interface VPC endpoints (ECR, Logs, SSM, Secrets Manager, STS)"

    tags = {
      Purpose   = "Interface-VPC-Endpoints"
      ManagedBy = "Terraform"
    }
  },
  backend_api = {
    vpc_key     = "main"
    name        = "backend-api-sg"
    description = "Security group for backend API ECS tasks"
    tags = {
      Name = "backend-api-sg"
    }
  }
}


# ====================================
# Ingress Rules
# ====================================
security_group_ingress_rules = {
  vpce_https_from_vpc = {
    security_group_key = "vpc_endpoint_sg"
    description        = "Allow HTTPS inbound from within the VPC for AWS service endpoints"
    ip_protocol        = "tcp"
    from_port          = 443
    to_port            = 443
    cidr_ipv4          = "10.0.0.0/16" # Your VPC CIDR - adjust if needed

    tags = {
      Rule = "HTTPS-Inbound"
    }
  },
  backend_from_alb = {
    security_group_key = "backend_api"
    description        = "Allow inbound from ALB"
    ip_protocol        = "tcp"
    from_port          = 8000
    to_port            = 8000
    cidr_ipv4          = "10.0.0.0/16" # Or better: reference ALB SG later
    tags               = { Rule = "ALB-to-Backend" }
  }

  # Optional: Add HTTP if any endpoint requires it (rare for these services)
  # vpce_http_from_vpc = {
  #   security_group_key = "vpc_endpoint_sg"
  #   description        = "Allow HTTP inbound from within the VPC"
  #   ip_protocol        = "tcp"
  #   from_port          = 80
  #   to_port            = 80
  #   cidr_ipv4          = "10.0.0.0/16"
  # }
}

# ====================================
# Egress Rules
# ====================================
security_group_egress_rules = {
  vpce_all_outbound = {
    security_group_key = "vpc_endpoint_sg"
    description        = "Allow all outbound traffic to reach AWS services"
    ip_protocol        = "-1" # All protocols
    cidr_ipv4          = "0.0.0.0/0"

    tags = {
      Rule = "All-Outbound"
    }
  },
  backend_to_vpce = {
    security_group_key = "backend_api"
    description        = "Allow outbound to VPC endpoints"
    ip_protocol        = "-1"
    cidr_ipv4          = "10.0.0.0/16" # VPC CIDR
    tags               = { Rule = "Backend-to-VPC-Endpoints" }
  }
}