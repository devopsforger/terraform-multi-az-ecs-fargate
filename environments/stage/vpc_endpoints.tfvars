# ====================================
# Gateway endpoints
# ====================================
gateway_endpoints = {
  s3 = {
    vpc_name         = "main"
    service_name     = "com.amazonaws.us-east-1.s3"
    route_table_keys = ["backend_private_az_a", "backend_private_az_b"]
    policy           = null
    tags             = { Name = "s3-endpoint" }
  }
}

# ====================================
# Interface endpoints
# ====================================
interface_endpoints = {
  ecr_api = {
    vpc_name            = "main"
    service_name        = "com.amazonaws.us-east-1.ecr.api"
    subnet_keys         = ["backend_private_1", "backend_private_2"]
    security_group_keys = ["vpc_endpoint_sg"]
    private_dns_enabled = true
    tags                = { Name = "ecr-api-endpoint" }
  },
  ecr_dkr = {
    vpc_name            = "main"
    service_name        = "com.amazonaws.us-east-1.ecr.dkr"
    subnet_keys         = ["backend_private_1", "backend_private_2"]
    security_group_keys = ["vpc_endpoint_sg"]
    private_dns_enabled = true
    tags                = { Name = "ecr-dkr-endpoint" }
  },
  logs = {
    vpc_name            = "main"
    service_name        = "com.amazonaws.us-east-1.logs"
    subnet_keys         = ["backend_private_1", "backend_private_2"]
    security_group_keys = ["vpc_endpoint_sg"]
    private_dns_enabled = true
    tags                = { Name = "logs-endpoint" }
  },
  secretsmanager = {
    vpc_name            = "main"
    service_name        = "com.amazonaws.us-east-1.secretsmanager"
    subnet_keys         = ["backend_private_1", "backend_private_2"]
    security_group_keys = ["vpc_endpoint_sg"]
    private_dns_enabled = true
    tags                = { Name = "secrets-endpoint" }
  },
  ssm = {
    vpc_name            = "main"
    service_name        = "com.amazonaws.us-east-1.ssm"
    subnet_keys         = ["backend_private_1", "backend_private_2"]
    security_group_keys = ["vpc_endpoint_sg"]
    private_dns_enabled = true
    tags                = { Name = "ssm-endpoint" }
  },
  sts = {
    vpc_name            = "main"
    service_name        = "com.amazonaws.us-east-1.sts"
    subnet_keys         = ["backend_private_1", "backend_private_2"]
    security_group_keys = ["vpc_endpoint_sg"]
    private_dns_enabled = true
    tags                = { Name = "sts-endpoint" }
  }
}
