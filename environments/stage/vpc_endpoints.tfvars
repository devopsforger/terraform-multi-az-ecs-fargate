# ====================================
# Gateway endpoints
# ====================================
gateway_endpoints = {
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

# ====================================
# VPC Endpoint Policies
# ====================================
endpoint_policies = {

  # ECR API Interface Endpoint Policy
  ecr_api = {
    policy = <<-EOF
      {
        "Version": "2012-10-17",
        "Statement": [
          {
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
              "ecr:GetAuthorizationToken",
              "ecr:BatchCheckLayerAvailability",
              "ecr:GetDownloadUrlForLayer",
              "ecr:DescribeRepositories",
              "ecr:ListImages",
              "ecr:DescribeImages",
              "ecr:BatchGetImage"
            ],
            "Resource": "*"
          }
        ]
      }
    EOF
  }

  # ECR Docker (DKR) Interface Endpoint Policy
  ecr_dkr = {
    policy = <<-EOF
      {
        "Version": "2012-10-17",
        "Statement": [
          {
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
              "ecr:GetAuthorizationToken",
              "ecr:BatchCheckLayerAvailability",
              "ecr:GetDownloadUrlForLayer",
              "ecr:BatchGetImage"
            ],
            "Resource": "*"
          }
        ]
      }
    EOF
  }

  # CloudWatch Logs Interface Endpoint Policy
  logs = {
    policy = <<-EOF
      {
        "Version": "2012-10-17",
        "Statement": [
          {
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
              "logs:PutLogEvents",
              "logs:CreateLogStream",
              "logs:DescribeLogStreams",
              "logs:CreateLogGroup",
              "logs:DescribeLogGroups"
            ],
            "Resource": "*"
          }
        ]
      }
    EOF
  }

  # Secrets Manager Interface Endpoint Policy
  secretsmanager = {
    policy = <<-EOF
      {
        "Version": "2012-10-17",
        "Statement": [
          {
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
              "secretsmanager:GetSecretValue",
              "secretsmanager:DescribeSecret"
            ],
            "Resource": "arn:aws:secretsmanager:us-east-1:*:secret:*"
          }
        ]
      }
    EOF
  }

  # SSM Interface Endpoint Policy
  ssm = {
    policy = <<-EOF
      {
        "Version": "2012-10-17",
        "Statement": [
          {
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
              "ssm:GetParameter",
              "ssm:GetParameters",
              "ssm:GetParametersByPath",
              "ssm:DescribeParameters",
              "ssm:GetDocument",
              "ssm:DescribeDocument",
              "ssm:ListDocuments"
            ],
            "Resource": "*"
          }
        ]
      }
    EOF
  }

  # STS Interface Endpoint Policy
  sts = {
    policy = <<-EOF
      {
        "Version": "2012-10-17",
        "Statement": [
          {
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
              "sts:AssumeRole",
              "sts:GetCallerIdentity",
              "sts:GetSessionToken",
              "sts:DecodeAuthorizationMessage"
            ],
            "Resource": "*"
          }
        ]
      }
    EOF
  }
}