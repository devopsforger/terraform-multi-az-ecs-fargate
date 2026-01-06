# terraform-multi-az-ecs-fargate

## Setting up and running the code

Here are all the runnable commands from your Makefile and what each does:

- **`make init-backend`**  
  Creates an S3 bucket for Terraform state (named `forger-tfstate-<account-id>`), enables versioning on it, and confirms readiness. Runs once to set up remote state storage.

- **`make stage-init`**  
  Initializes Terraform for the **stage** environment using the backend config in `environments/stage/backend.hcl`. Use `-reconfigure` to force backend reconfiguration.

- **`make prod-init`**  
  Initializes Terraform for the **prod** environment using the backend config in `environments/prod/backend.hcl`. Use `-reconfigure` to force backend reconfiguration.

- **`make init-all`**  
  Runs both `stage-init` and `prod-init` sequentially to initialize all environments.

- **`make stage-plan`**  
  Runs `terraform plan` for **stage** environment, automatically loading all `.tfvars` files found in `environments/stage/`. Shows a preview of changes.

- **`make stage-apply`**  
  Runs `terraform apply` for **stage** environment, automatically loading all `.tfvars` files found in `environments/stage/`. Actually applies infrastructure changes.

- **`make prod-plan`**  
  Runs `terraform plan` for **prod** environment, automatically loading all `.tfvars` files found in `environments/prod/`. Shows a preview of changes.

- **`make prod-apply`**  
  Runs `terraform apply` for **prod** environment, automatically loading all `.tfvars` files found in `environments/prod/`. Actually applies infrastructure changes.

- **`make debug-stage`**  
  Debug command that lists all stage `.tfvars` files detected and shows the exact `-var-file` flags that will be passed to Terraform.

- **`make debug-prod`**  
  Debug command that lists all prod `.tfvars` files detected and shows the exact `-var-file` flags that will be passed to Terraform.

- **`make infracost`**  
  Runs `infracost breakdown` on the entire project (`.` path) to estimate cloud costs, including showing skipped resources.

- **`make fmt`**  
  Runs `terraform fmt -recursive` to format all Terraform files in the project with consistent style.

- **`make validate`**  
  Runs `terraform validate` to check Terraform configuration syntax and internal consistency.

**Typical workflow:**  
`init-backend` → `stage-init` → `debug-stage` → `stage-plan` → `stage-apply` → repeat for prod.