# ====================================
# KMS Key for Secrets Encryption
# ====================================
kms_keys = {
  secrets = {
    description         = "KMS key for encrypting secrets"
    enable_key_rotation = true
    tags = {
      Name = "forger-stage-secrets-kms"
    }
  }
}

# ====================================
# KMS Alias
# ====================================
kms_aliases = {
  "alias/forger-stage-secrets" = {
    kms_key_name = "secrets"
  }
}

# ====================================
# Secrets Manager Secrets
# ====================================
secrets = {
  "forger/stage/backend/db-password" = {
    description = "PostgreSQL password for backend DB"
    kms_key_id  = "secrets"
    tags = {
      Name = "backend-db-password"
    }
  }
}

# ====================================
# Secret Versions
# ====================================
secret_versions = {
  backend_db_password = {
    secret_id     = "forger/stage/backend/db-password"
    secret_string = "secure_password_here" # 🔒 In real life, use TF_VAR or CI/CD secret injection
    tags = {
      Name = "backend-db-password-v1"
    }
  }
}

# ====================================
# SSM Parameters (Non-secret config)
# ====================================
ssm_parameters = {
  backend-app_url = {
    name        = "/forger/stage/backend/api-url"
    description = "Backend API URL"
    type        = "String"
    value       = "https://api.stage.forger.dev"
    alb_key   = "backend-app"
    tags = {
      Name = "backend-app-url"
    }
  }

  feature_flags = {
    name        = "/forger/stage/backend/feature-flags"
    description = "Feature flags for backend"
    type        = "StringList"
    value       = "auth_v2,metrics_v1"
    tags = {
      Name = "feature-flags"
    }
  }
}