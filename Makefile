.PHONY: help init-backend stage-init prod-init init-all stage-plan stage-apply prod-plan prod-apply \
	stage-destroy prod-destroy stage-destroy-all prod-destroy-all \
	debug-stage debug-prod infracost fmt validate

AWS_REGION := us-east-1

# terraform state details
TF_STATE_BUCKET_NAME := forger-tfstate-$(shell aws sts get-caller-identity --profile $(AWS_PROFILE) --query "Account" --output text)

# Export actual credentials as env vars (only works with AWS CLI >= 2.13.0)
CREDENTIAL_ENV := $(shell aws configure export-credentials --profile $(AWS_PROFILE) --format env | sed 's/^export //')

# Auto-detect all tfvars files for each environment
STAGE_TFVARS := $(wildcard environments/stage/*.tfvars)
PROD_TFVARS := $(wildcard environments/prod/*.tfvars)

# Convert file list to -var-file flags
STAGE_FLAGS := $(foreach file,$(STAGE_TFVARS),-var-file=$(file))
PROD_FLAGS := $(foreach file,$(PROD_TFVARS),-var-file=$(file))

help: ## Show this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

init-backend: ## Create S3 bucket for Terraform remote state
	@echo "Creating S3 bucket for Terraform state..."
	aws s3 mb s3://$(TF_STATE_BUCKET_NAME) --region $(AWS_REGION) --profile $(AWS_PROFILE)
	@echo "Enabling versioning on the state bucket..."
	aws s3api put-bucket-versioning \
		--bucket $(TF_STATE_BUCKET_NAME) \
		--versioning-configuration Status=Enabled \
		--profile $(AWS_PROFILE)
	@echo "Terraform backend bucket '$(TF_STATE_BUCKET_NAME)' is ready."

stage-init: ## Initialize Terraform backend for stage
	@env $(CREDENTIAL_ENV) terraform init --reconfigure \
		-backend-config="bucket=$(TF_STATE_BUCKET_NAME)" \
		-backend-config="key=stage/terraform.tfstate" \
		-backend-config="region=$(AWS_REGION)"

prod-init: ## Initialize Terraform backend for prod
	@env $(CREDENTIAL_ENV) terraform init --reconfigure \
		-backend-config="bucket=$(TF_STATE_BUCKET_NAME)" \
		-backend-config="key=prod/terraform.tfstate" \
		-backend-config="region=$(AWS_REGION)"

init-all: ## Initialize both stage and prod backends
	stage-init prod-init

stage-plan: ## Plan Terraform changes for stage
	@echo "Loading stage tfvars: $(STAGE_TFVARS)"
	@env $(CREDENTIAL_ENV) terraform plan $(STAGE_FLAGS)

stage-apply: ## Apply Terraform changes for stage
	@env $(CREDENTIAL_ENV) terraform apply $(STAGE_FLAGS)

prod-plan: ## Plan Terraform changes for prod
	@echo "Loading prod tfvars: $(PROD_TFVARS)"
	@env $(CREDENTIAL_ENV) terraform plan $(PROD_FLAGS)

prod-apply: ## Apply Terraform changes for prod
	@env $(CREDENTIAL_ENV) terraform apply $(PROD_FLAGS)

# --- DESTROY COMMANDS ---

stage-destroy: ## Destroy stage infrastructure (keeps state bucket)
	@env $(CREDENTIAL_ENV) terraform destroy $(STAGE_FLAGS)

prod-destroy: ## Destroy prod infrastructure (keeps state bucket)
	@env $(CREDENTIAL_ENV) terraform destroy $(PROD_FLAGS)

stage-destroy-all: ## Destroy stage infra + delete state bucket (including all versions)
	@echo "Destroying stage infrastructure..."
	@env $(CREDENTIAL_ENV) terraform destroy -auto-approve $(STAGE_FLAGS)
	@echo "Deleting all versions in state bucket: $(TF_STATE_BUCKET_NAME)"
	@aws s3api list-object-versions --bucket $(TF_STATE_BUCKET_NAME) --profile $(AWS_PROFILE) --output json | \
		jq '{Objects: ([.Versions[], .DeleteMarkers[]] | map({Key:.Key, VersionId:.VersionId})), Quiet: true}' | \
		aws s3api delete-objects --bucket $(TF_STATE_BUCKET_NAME) --delete file:///dev/stdin --profile $(AWS_PROFILE)
	@echo "Deleting state bucket: $(TF_STATE_BUCKET_NAME)"
	@aws s3 rb s3://$(TF_STATE_BUCKET_NAME) --region $(AWS_REGION) --profile $(AWS_PROFILE)

prod-destroy-all: ## Destroy prod infra + delete state bucket (including all versions)
	@echo "Destroying prod infrastructure..."
	@env $(CREDENTIAL_ENV) terraform destroy -auto-approve $(PROD_FLAGS)
	@echo "Deleting all versions in state bucket: $(TF_STATE_BUCKET_NAME)"
	@aws s3api list-object-versions --bucket $(TF_STATE_BUCKET_NAME) --profile $(AWS_PROFILE) --output json | \
		jq '{Objects: ([.Versions[], .DeleteMarkers[]] | map({Key:.Key, VersionId:.VersionId})), Quiet: true}' | \
		aws s3api delete-objects --bucket $(TF_STATE_BUCKET_NAME) --delete file:///dev/stdin --profile $(AWS_PROFILE)
	@echo "Deleting state bucket: $(TF_STATE_BUCKET_NAME)"
	@aws s3 rb s3://$(TF_STATE_BUCKET_NAME) --region $(AWS_REGION) --profile $(AWS_PROFILE)

# --- DEBUG & UTILITIES ---

# Debug command to see what files are loaded
debug-stage: ## Debug: list stage .tfvars files
	@echo "Stage TFVARS files:"
	@for file in $(STAGE_TFVARS); do echo "  - $$file"; done
	@echo "Flags: $(STAGE_FLAGS)"

debug-prod: ## Debug: list prod .tfvars files
	@echo "Prod TFVARS files:"
	@for file in $(PROD_TFVARS); do echo "  - $$file"; done
	@echo "Flags: $(PROD_FLAGS)"
	
infracost: ## Show cost estimate using Infracost
	infracost breakdown --path . --show-skipped

fmt: ## Format all .tf files
	terraform fmt -recursive

validate: ## Validate Terraform configuration
	terraform validate