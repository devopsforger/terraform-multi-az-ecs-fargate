ecs_clusters = {
  "backend" = {
    name = "backend-prod"
    tags = {
      Name        = "backend-prod-cluster"
      Environment = "production"
      Service     = "fastapi"
    }
  }
}

ecs_task_definitions = {
  "backend_api" = {
    family                   = "backend-api"
    requires_compatibilities = ["FARGATE"]
    network_mode             = "awsvpc"
    cpu                      = 512
    memory                   = 1024

    execution_role_arn = "arn:aws:iam::123456789012:role/ecsTaskExecutionRole"
    task_role_arn      = "arn:aws:iam::123456789012:role/backendTaskRole"

    container_definitions = [
      {
        name      = "backend-api"
        image     = "123456789012.dkr.ecr.us-east-1.amazonaws.com/backend-api:latest"
        essential = true

        portMappings = [
          {
            containerPort = 8000
            protocol      = "tcp"
          }
        ]

        healthCheck = {
          command     = ["CMD-SHELL", "curl -f http://localhost:8000/health || exit 1"]
          interval    = 30
          timeout     = 5
          retries     = 3
          startPeriod = 20
        }

        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = "/ecs/backend-api"
            awslogs-region        = "us-east-1"
            awslogs-stream-prefix = "ecs"
          }
        }
      }
    ]

    tags = {
      Name        = "backend-api-task"
      Environment = "production"
    }
  }
}

ecs_services = {
  "backend_api" = {
    name             = "backend-api"
    cluster_key      = "backend"
    task_def_key     = "backend_api"
    desired_count    = 2
    launch_type      = "FARGATE"
    platform_version = "LATEST"

    assign_public_ip = false

    subnets = [
      "backend_private_1",
      "backend_private_2"
    ]

    security_groups = [
      "backend_api"
    ]

    target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/backend-api/abc123"

    container_name = "backend-api"
    container_port = 8000

    tags = {
      Name        = "backend-api-service"
      Environment = "production"
    }
  }
}
