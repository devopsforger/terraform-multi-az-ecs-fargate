ecs_clusters = {
  "backend" = {
    name = "backend-stage"
    tags = {
      Name    = "backend-stage-cluster"
      Service = "fastapi"
    }
  }
}

ecs_task_definitions = {
  "backend-app" = {
    family                   = "backend-app"
    requires_compatibilities = ["FARGATE"]
    network_mode             = "awsvpc"
    cpu                      = 512
    memory                   = 1024

    execution_role_name = "forger-stage-ecs-task-execution"
    task_role_name      = "forger-stage-ecs-task"

    container_definitions = [
      {
        name           = "backend-app"
        image          = "backend-app"
        image_repo_key = "backend-app"
        essential      = true

        portMappings = [
          {
            containerPort = 8000
            protocol      = "tcp"
          }
        ]

        healthCheck = {
          command     = ["CMD-SHELL", "ps aux | grep -v grep | grep uvicorn || exit 1"]
          interval    = 30
          timeout     = 5
          retries     = 3
          startPeriod = 20
        }

        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = "/ecs/backend-app"
            awslogs-region        = "us-east-1"
            awslogs-stream-prefix = "ecs"
            awslogs-create-group  = "true"
          }
        }
      }
    ]

    tags = {
      Name = "backend-app-task"
    }
  }
}

ecs_services = {
  "backend-app" = {
    name             = "backend-app"
    cluster_key      = "backend"
    task_def_key     = "backend-app"
    desired_count    = 2
    launch_type      = "FARGATE"
    platform_version = "LATEST"

    assign_public_ip = false

    subnets = [
      "backend_private_1",
      "backend_private_2"
    ]

    security_groups = [
      "backend-app"
    ]

    target_group_name = "backend-app"

    container_name                    = "backend-app"
    container_port                    = 8000
    health_check_grace_period_seconds = 180

    tags = {
      Name = "backend-app-service"
    }
  }
}
