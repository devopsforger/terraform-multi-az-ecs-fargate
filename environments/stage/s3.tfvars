# ====================================
# S3 Bucket for Next.js Frontend
# ====================================
s3_buckets = {
  frontend = {
    bucket_prefix = "forger-stage-frontend-" # Auto-generates unique name
    force_destroy = true                     # Only for stage! Set to false in prod

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

    tags = {
      Name = "forger-stage-frontend-bucket"
    },
  }
}

s3_bucket_public_access_blocks = {
  frontend = {
    block_public_acls       = false
    block_public_policy     = false
    ignore_public_acls      = false
    restrict_public_buckets = false
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
        sid     = "AllowPublicReadForStaticWebsite"
        effect  = "Allow"
        actions = ["s3:GetObject"]

        principals = [
          {
            type        = "*"
            identifiers = ["*"]
          }
        ]
      }
    ]
  }
}