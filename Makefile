# ─── Reddit Clone DevOps Project ─────────────────────────────────────────────
.PHONY: help build dev prod test lint clean monitoring k8s-dev k8s-prod

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# ─── Docker ──────────────────────────────────────────────────────────────────
build: ## Build Docker image locally
	docker build -t reddit-clone:latest ./app

dev: ## Run app in dev mode with Docker Compose
	docker compose -f docker-compose.dev.yml up --build

dev-d: ## Run app in dev mode (detached)
	docker compose -f docker-compose.dev.yml up --build -d

prod: ## Run app in prod mode with Docker Compose
	docker compose -f docker-compose.prod.yml up -d

stop: ## Stop all containers
	docker compose -f docker-compose.dev.yml down
	docker compose -f docker-compose.prod.yml down

# ─── Tests ───────────────────────────────────────────────────────────────────
test: ## Run tests
	cd app && npm test

lint: ## Run linter
	cd app && npm run lint

# ─── Kubernetes ──────────────────────────────────────────────────────────────
k8s-dev: ## Deploy to Kubernetes dev namespace
	kubectl apply -f k8s/base/namespace.yaml
	kubectl apply -f k8s/dev/
	kubectl apply -f k8s/base/deployment.yaml -n reddit-clone-dev
	kubectl apply -f k8s/base/service.yaml -n reddit-clone-dev

k8s-prod: ## Deploy to Kubernetes prod namespace
	kubectl apply -f k8s/base/namespace.yaml
	kubectl apply -f k8s/prod/
	kubectl apply -f k8s/base/deployment.yaml -n reddit-clone-prod
	kubectl apply -f k8s/base/service.yaml -n reddit-clone-prod
	kubectl apply -f k8s/base/ingress.yaml -n reddit-clone-prod

# ─── Monitoring ──────────────────────────────────────────────────────────────
monitoring: ## Start Prometheus + Grafana monitoring stack
	docker compose -f monitoring/docker-compose.monitoring.yml up -d

monitoring-stop: ## Stop monitoring stack
	docker compose -f monitoring/docker-compose.monitoring.yml down

# ─── Terraform ───────────────────────────────────────────────────────────────
tf-init: ## Initialize Terraform
	cd terraform && terraform init

tf-plan-dev: ## Plan Terraform for dev
	cd terraform && terraform plan -var-file=terraform.tfvars.dev

tf-plan-prod: ## Plan Terraform for prod
	cd terraform && terraform plan -var-file=terraform.tfvars.prod

tf-apply-dev: ## Apply Terraform for dev
	cd terraform && terraform apply -var-file=terraform.tfvars.dev -auto-approve

tf-apply-prod: ## Apply Terraform for prod (requires confirmation)
	cd terraform && terraform apply -var-file=terraform.tfvars.prod

tf-destroy-dev: ## Destroy dev infrastructure
	cd terraform && terraform destroy -var-file=terraform.tfvars.dev -auto-approve

# ─── Security ────────────────────────────────────────────────────────────────
trivy-scan: ## Scan Docker image with Trivy
	trivy image reddit-clone:latest

trivy-fs: ## Scan filesystem with Trivy
	trivy fs ./app

# ─── Clean ───────────────────────────────────────────────────────────────────
clean: ## Clean up everything
	docker compose -f docker-compose.dev.yml down -v --rmi all 2>/dev/null || true
	docker compose -f docker-compose.prod.yml down -v --rmi all 2>/dev/null || true
	docker compose -f monitoring/docker-compose.monitoring.yml down -v 2>/dev/null || true
