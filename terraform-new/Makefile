TF_SHARED_DIR := infra/terraform/environments/dev-prod-shared-cluster
TF_STATE_DIR := infra/terraform/bootstrap/remote-state

.PHONY: fmt validate validate-state validate-shared plan-state plan-shared

fmt:
	terraform -chdir=$(TF_STATE_DIR) fmt -recursive
	terraform -chdir=$(TF_SHARED_DIR) fmt -recursive

validate: validate-state validate-shared

validate-state:
	terraform -chdir=$(TF_STATE_DIR) init -backend=false
	terraform -chdir=$(TF_STATE_DIR) validate

validate-shared:
	terraform -chdir=$(TF_SHARED_DIR) init -backend=false
	terraform -chdir=$(TF_SHARED_DIR) validate

plan-state:
	terraform -chdir=$(TF_STATE_DIR) init
	terraform -chdir=$(TF_STATE_DIR) plan -var-file=terraform.tfvars.example

plan-shared:
	terraform -chdir=$(TF_SHARED_DIR) init -backend=false
	terraform -chdir=$(TF_SHARED_DIR) plan -var-file=terraform.tfvars.example
