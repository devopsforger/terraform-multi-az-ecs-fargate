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
  backend-app = {
    vpc_key     = "main"
    name        = "backend-app-sg"
    description = "Security group for backend API ECS tasks"
    tags = {
      Name = "backend-app-sg"
    }
  },
  database_sg = {
    vpc_key     = "main"
    name        = "forger-database-sg"
    description = "Allow backend ECS tasks to access RDS"
    tags = {
      Name = "forger-database-sg"
    }
  },
  backend_alb = {
    vpc_key     = "main"
    name        = "backend-alb-sg"
    description = "Public ALB security group for backend service"
    tags = {
      Name = "backend-alb-sg"
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
    security_group_key            = "backend-app"
    description                   = "Allow inbound from ALB"
    ip_protocol                   = "tcp"
    from_port                     = 8000
    to_port                       = 8000
    referenced_security_group_key = "backend-app"
    tags                          = { Rule = "ALB-to-Backend" }
  },

  db_from_backend = {
    security_group_key            = "database_sg"
    description                   = "Allow inbound from backend ECS tasks"
    ip_protocol                   = "tcp"
    from_port                     = 5432 # PostgreSQL
    to_port                       = 5432
    referenced_security_group_key = "backend-app"
  },

  alb_http = {
    security_group_key = "backend_alb"
    ip_protocol        = "tcp"
    from_port          = 443
    to_port            = 443
    cidr_ipv4          = "0.0.0.0/0"
  }
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
    security_group_key            = "backend-app"
    description                   = "Allow outbound to VPC endpoints"
    ip_protocol                   = "-1"
    referenced_security_group_key = "vpc_endpoint_sg"
    tags                          = { Rule = "Backend-to-VPC-Endpoints" }
  }
}