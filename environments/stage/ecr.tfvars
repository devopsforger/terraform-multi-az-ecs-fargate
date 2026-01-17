# ====================================
# ECR Repositories
# ====================================
ecr_repositories = {
  backend_app = {
    name                 = "forger-stage-backend-app"
    image_tag_mutability = "IMMUTABLE"
    image_scanning_configuration = {
      scan_on_push = true
    }
    tags = {
      Environment = "stage"
      Project     = "forger"
      Name        = "backend-app"
    }
  }

  frontend_app = {
    name                 = "forger-stage-frontend-app"
    image_tag_mutability = "MUTABLE"
    image_scanning_configuration = {
      scan_on_push = false
    }
    tags = {
      Environment = "stage"
      Project     = "forger"
      Name        = "frontend-app"
    }
  }
}


# ====================================
# ECR Repositories Policies
# ====================================
ecr_repository_policies = {
  backend_app_policy = {
    repository = "forger-stage-backend-app"
    statements = [
      {
        sid    = "AllowBackendTeam"
        effect = "Allow"
        principals = [
          {
            type        = "AWS"
            identifiers = ["arn:aws:iam::014208335592:role/backend-team-role"]
          }
        ]
        actions = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeRepositories",
          "ecr:GetRepositoryPolicy",
          "ecr:ListImages"
        ]
      }
    ]
  }

  frontend_app_policy = {
    repository = "forger-stage-frontend-app"
    statements = [
      {
        sid    = "AllowFrontendTeam"
        effect = "Allow"
        principals = [
          {
            type        = "AWS"
            identifiers = ["arn:aws:iam::014208335592:role/frontend-team-role"]
          }
        ]
        actions = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:DescribeRepositories",
          "ecr:GetRepositoryPolicy",
          "ecr:ListImages"
        ]
      }
    ]
  }
}
