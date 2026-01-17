# IAM Roles
iam_roles = {
  forger-stage-ecs-task-execution = {
    assume_role_policy = <<-EOF
      {
        "Version": "2012-10-17",
        "Statement": [
          {
            "Effect": "Allow",
            "Principal": {
              "Service": "ecs-tasks.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
          }
        ]
      }
    EOF

    tags = {
      Name = "forger-stage-ecs-task-execution"
    }
  }

  forger-stage-ecs-task = {
    assume_role_policy = <<-EOF
      {
        "Version": "2012-10-17",
        "Statement": [
          {
            "Effect": "Allow",
            "Principal": {
              "Service": "ecs-tasks.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
          }
        ]
      }
    EOF
    tags = {
      Name = "forger-stage-ecs-task"
    }
  }
}

# IAM Policies
iam_policies = {
  forger-stage-backend-app-policy = {
    description = "Permissions for backend app to access Secrets Manager, SSM, etc."
    policy      = <<-EOF
      {
        "Version": "2012-10-17",
        "Statement": [
          {
            "Effect": "Allow",
            "Action": [
              "secretsmanager:GetSecretValue",
              "secretsmanager:DescribeSecret"
            ],
            "Resource": "arn:aws:secretsmanager:us-east-1:014208335592:secret:*"
          },
          {
            "Effect": "Allow",
            "Action": [
              "ssm:GetParameter",
              "ssm:GetParameters",
              "ssm:GetParametersByPath"
            ],
            "Resource": "arn:aws:ssm:us-east-1:*:parameter/*"
          }
        ]
      }
    EOF
    tags = {
      Name = "forger-stage-backend-app-policy"
    }
  }
}

# Role-Policy Attachments (unchanged)
iam_role_policy_attachments = {
  ecs_task_execution_to_aws_managed = {
    role_name  = "forger-stage-ecs-task-execution"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  }

  ecs_task_to_custom_policy = {
    role_name  = "forger-stage-ecs-task"
    policy_arn = "arn:aws:iam::014208335592:policy/forger-stage-backend-app-policy"
  }
}
