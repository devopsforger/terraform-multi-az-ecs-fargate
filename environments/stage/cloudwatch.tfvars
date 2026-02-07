cloudwatch_log_groups = {
  backend-app = {
    name              = "/ecs/backend-app"
    retention_in_days = 14
    kms_key_id        = "secrets" # Key in kms_key map
  }
}