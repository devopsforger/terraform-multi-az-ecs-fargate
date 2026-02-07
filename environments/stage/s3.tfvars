# ====================================
# S3 Bucket for Next.js Frontend
# ====================================
s3_buckets = {
  frontend = {
    bucket_prefix = "forger-stage-frontend-" # Auto-generates unique name
    force_destroy = true                     # Only for stage! Set to false in prod
    tags = {
      Name = "forger-stage-frontend-bucket"
    },
    server_side_encryption_rules = [
      {
        apply_server_side_encryption_by_default = {
          sse_algorithm = "AES256"
        }
      }
    ],
    versioning_configuration = {
      status     = "Enabled"
      mfa_delete = "Disabled"
    }
  }
}

# ====================================
# S3 Bucket Website Configuration
# ====================================
s3_bucket_website_configs = {
  frontend = {
    bucket_key = "frontend"
    index_document = {
      suffix = "index.html"
    }
    error_document = {
      key = "error.html"
    }
    tags = {
      Name = "forger-stage-frontend-website"
    }
  }
}

# ====================================
# S3 Bucket Policy (Allow public read access)
# ====================================
s3_policy_documents = {
  frontend = {
    bucket_key = "frontend"

    statements = [
      {
        sid     = "AllowCloudFrontOAC"
        effect  = "Allow"
        actions = ["s3:GetObject"]


        principals = [
          {
            type        = "Service"
            identifiers = ["cloudfront.amazonaws.com"]
          }
        ]

        # Static identifier - will be resolved in s3.tf
        cloudfront_dist_key = "frontend"
      }
    ]

    tags = {
      Name = "forger-stage-frontend-policy"
    }
  }
}