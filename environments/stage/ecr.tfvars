# ====================================
# ECR Repositories
# ====================================
ecr_repositories = {
  backend-app = {
    name                 = "forger-stage-backend-app"
    image_tag_mutability = "IMMUTABLE"
    image_scanning_configuration = {
      scan_on_push = true
    }
    tags = {
      Project = "forger"
      Name    = "backend-app"
    }
  }
}


# ====================================
# ECR Repositories Policies
# ====================================
ecr_repository_policies = {
  backend-app_policy = {
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
}
