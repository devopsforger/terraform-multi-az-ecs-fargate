# ====================================
# DB Subnet Group
# ====================================
db_subnet_groups = {
  main = {
    subnet_keys = [
      "database_private_1",
      "database_private_2"
    ]
    tags = {
      Name = "forger-stage-db-subnet-group"
    }
  }
}

# ====================================
# DB Parameter Group (example for PostgreSQL)
# ====================================
db_parameter_groups = {
  postgres14 = {
    family      = "postgres14"
    description = "Custom parameters for Forger PostgreSQL 14"
    parameters = [
      {
        name  = "shared_preload_libraries"
        value = "pg_stat_statements"
      },
      {
        name  = "pg_stat_statements.track"
        value = "all"
      }
    ]
    tags = {
      Name = "forger-stage-postgres14-params"
    }
  }
}

# ====================================
# DB Option Group (example for MySQL; omit for PostgreSQL)
# ====================================
# db_option_groups = {
#   mysql8 = {
#     engine_name           = "mysql"
#     major_engine_version  = "8.0"
#     description           = "MySQL 8 options"
#     options = [
#       {
#         name    = "MEMCACHED"
#         version = "1.6.17"
#       }
#     ]
#     tags = { Name = "forger-stage-mysql8-options" }
#   }
# }

# ====================================
# DB Instance
# ====================================
db_instances = {
  backend_db = {
    identifier              = "forger-stage-backend-db"
    engine                  = "postgres"
    engine_version          = "14.10"
    instance_class          = "db.t4g.micro" # Free tier eligible
    allocated_storage       = 20
    max_allocated_storage   = 100 # Auto-scaling storage
    db_subnet_group_key     = "main"
    db_parameter_group_key  = "postgres14"
    db_option_group_key     = null # Not used for PostgreSQL
    vpc_security_group_keys = ["database_sg"]
    multi_az                = true # Highly available
    publicly_accessible     = false
    username                = "forger"
    password                = "secure_password_here"
    password_secret_key     = "backend_db_password" # Key in secret_versions map for DB password
    backup_retention_period = 7
    skip_final_snapshot     = false
    deletion_protection     = true
    tags = {
      Name = "forger-stage-backend-db"
    }
  }
}