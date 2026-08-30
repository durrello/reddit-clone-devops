# Reddit Clone — Full DevOps Project

A production-ready Reddit clone application showcasing modern DevOps practices: containerization, orchestration, CI/CD, IaC, monitoring, security, and disaster recovery.

---

## Table of Contents

- [Overview](#overview)
- [Architecture Diagram](#architecture-diagram)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Setup Steps](#setup-steps)
- [Deploying Dev & Prod](#deploying-dev--prod)
- [CI/CD Pipeline](#cicd-pipeline)
- [Monitoring](#monitoring)
- [Security (DevSecOps)](#security-devsecops)
- [Disaster Recovery](#disaster-recovery)
- [Environment Differences](#environment-differences)

---

## Overview

This project deploys a Next.js Reddit clone through a full DevOps pipeline:

| Requirement | Implementation |
|---|---|
| Dockerization | Multi-stage Dockerfile, GHCR registry |
| Multi-environment | Dev & Prod via K8s namespaces + env files |
| Testing | Jest unit tests in CI |
| Kubernetes | Deployment, Service, ConfigMap, Secret, Ingress |
| CI/CD | GitHub Actions (build → test → scan → push → deploy) |
| IaC | Terraform (AWS VPC + EKS + ECR) |
| Monitoring | Prometheus + Grafana + cAdvisor + Node Exporter |
| Security | Trivy image scan, dependency scan, K8s Secrets, no hardcoded secrets |
| Disaster Recovery | Rollback strategy, IaC reprovisioning, backup docs |
| Documentation | This README + architecture diagram |

---

## Architecture Diagram

```
┌──────────────────────────────────────────────────────────────────────────┐
│                          GITHUB ACTIONS CI/CD                             │
│  ┌──────┐   ┌──────┐   ┌────────┐   ┌──────────┐   ┌───────────────┐  │
│  │ Lint │──▶│ Test │──▶│ Trivy  │──▶│Build/Push│──▶│ Deploy to K8s │  │
│  └──────┘   └──────┘   │  Scan  │   │  (GHCR)  │   └───────────────┘  │
│                         └────────┘   └──────────┘          │            │
└────────────────────────────────────────────────────────────┼────────────┘
                                                             │
                    ┌────────────────────────────────────────┼──────────┐
                    │              AWS (Terraform)            │          │
                    │  ┌─────────────────────────────────────▼────────┐ │
                    │  │                 EKS Cluster                   │ │
                    │  │  ┌─────────────────┐  ┌─────────────────┐   │ │
                    │  │  │  Namespace: DEV  │  │  Namespace: PROD │   │ │
                    │  │  │  ┌───────────┐  │  │  ┌───────────┐  │   │ │
                    │  │  │  │ Deployment│  │  │  │ Deployment │  │   │ │
                    │  │  │  │  (1 pod)  │  │  │  │  (2 pods)  │  │   │ │
                    │  │  │  └───────────┘  │  │  └───────────┘  │   │ │
                    │  │  │  ┌───────────┐  │  │  ┌───────────┐  │   │ │
                    │  │  │  │  Service  │  │  │  │  Service   │  │   │ │
                    │  │  │  └───────────┘  │  │  └───────────┘  │   │ │
                    │  │  │  ┌───────────┐  │  │  ┌───────────┐  │   │ │
                    │  │  │  │ ConfigMap │  │  │  │  Ingress   │  │   │ │
                    │  │  │  └───────────┘  │  │  └───────────┘  │   │ │
                    │  │  └─────────────────┘  └─────────────────┘   │ │
                    │  └─────────────────────────────────────────────┘ │
                    │  ┌────────────┐  ┌──────────────┐                │
                    │  │    VPC     │  │     ECR      │                │
                    │  │ (2 AZs)   │  │  (registry)  │                │
                    │  └────────────┘  └──────────────┘                │
                    └──────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────┐
│              MONITORING STACK                        │
│  ┌────────────┐  ┌─────────┐  ┌──────────────┐    │
│  │ Prometheus │──│ Grafana │  │ Node Exporter│    │
│  │  (metrics) │  │(dashbrd)│  │  + cAdvisor  │    │
│  └────────────┘  └─────────┘  └──────────────┘    │
└────────────────────────────────────────────────────┘
```

---

## Tech Stack

| Layer | Technology |
|---|---|
| Application | Next.js 12, React, TypeScript, Chakra UI, Firebase |
| Containerization | Docker (multi-stage build) |
| Registry | GitHub Container Registry (GHCR) |
| Orchestration | Kubernetes (EKS) |
| CI/CD | GitHub Actions |
| IaC | Terraform (AWS provider) |
| Monitoring | Prometheus, Grafana, cAdvisor, Node Exporter |
| Security | Trivy (image + filesystem scan), K8s Secrets |
| Cloud | AWS (VPC, EKS, ECR, ALB) |

---

## Project Structure

```
project3days/
├── app/                        # Next.js application source
│   ├── Dockerfile              # Multi-stage Docker build
│   ├── __tests__/              # Unit tests (Jest)
│   ├── src/                    # Application code
│   └── package.json
├── k8s/                        # Kubernetes manifests
│   ├── base/                   # Shared (Deployment, Service, Ingress, Namespace)
│   ├── dev/                    # Dev overrides (ConfigMap, Secret)
│   └── prod/                   # Prod overrides (ConfigMap, Secret)
├── terraform/                  # Infrastructure as Code
│   ├── main.tf                 # VPC + EKS + ECR
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars.dev
│   └── terraform.tfvars.prod
├── monitoring/                 # Observability stack
│   ├── docker-compose.monitoring.yml
│   ├── prometheus/
│   └── grafana/
├── envs/                       # Environment variable files
│   ├── .env.dev
│   ├── .env.prod
│   └── .env.example
├── .github/workflows/          # CI/CD pipeline
│   └── ci-cd.yml
├── docker-compose.dev.yml      # Docker Compose (dev)
├── docker-compose.prod.yml     # Docker Compose (prod)
├── Makefile                    # Common commands
└── README.md                   # This file
```

---

## Setup Steps

### Prerequisites

- Docker & Docker Compose
- Node.js 18+
- kubectl
- Terraform >= 1.5
- AWS CLI (configured)
- Trivy (for local security scans)

### 1. Clone and configure

```bash
git clone https://github.com/durrello/reddit-clone-devops.git
cd reddit-clone-devops

# Copy environment template
cp envs/.env.example envs/.env.dev
cp envs/.env.example envs/.env.prod
# Edit the files with your Firebase credentials
```

### 2. Run locally with Docker

```bash
# Development
make dev

# Or detached
make dev-d

# Production mode
make prod
```

### 3. Run tests

```bash
make test
```

### 4. Deploy to Kubernetes (local with Minikube/Kind)

```bash
# Start minikube
minikube start

# Deploy to dev
make k8s-dev

# Deploy to prod
make k8s-prod
```

### 5. Provision cloud infrastructure

```bash
make tf-init
make tf-plan-dev
make tf-apply-dev
```

### 6. Start monitoring

```bash
make monitoring
# Grafana: http://localhost:3001 (admin/admin)
# Prometheus: http://localhost:9090
```

---

## Deploying Dev & Prod

### Dev Environment
- **Trigger:** Push to `dev` branch → auto-deploy
- **K8s Namespace:** `reddit-clone-dev`
- **Replicas:** 1
- **Node size:** t3.medium
- **Config:** `k8s/dev/configmap.yaml` + `envs/.env.dev`

### Prod Environment
- **Trigger:** Push to `main` branch → requires manual approval
- **K8s Namespace:** `reddit-clone-prod`
- **Replicas:** 2
- **Node size:** t3.large
- **Config:** `k8s/prod/configmap.yaml` + `envs/.env.prod`
- **Extras:** Ingress with TLS, stricter resource limits

### Configuration Differences

| Setting | Dev | Prod |
|---|---|---|
| NODE_ENV | development | production |
| Replicas | 1 | 2 |
| Instance type | t3.medium | t3.large |
| NAT Gateway | Single | Multi-AZ |
| Ingress/TLS | No | Yes |
| Deploy trigger | Auto on push | Manual approval |

---

## CI/CD Pipeline

The pipeline (`.github/workflows/ci-cd.yml`) runs on every push:

```
Push → Lint → Test → Security Scan → Build Image → Push to GHCR → Deploy
```

### Stages

1. **Test** — `npm run lint` + `npm test`
2. **Security Scan** — Trivy filesystem scan for vulnerabilities
3. **Build & Push** — Multi-stage Docker build → push to GHCR
4. **Image Scan** — Trivy scans the built image
5. **Deploy Dev** — Auto-deploy on `dev` branch push
6. **Deploy Prod** — Deploy on `main` branch push (requires environment approval)

### Branching Strategy

- `dev` → development/testing features
- `main` → stable production releases
- Feature branches → PR into `dev`

---

## Monitoring

### Stack: Prometheus + Grafana

```bash
make monitoring
```

| Service | URL | Purpose |
|---|---|---|
| Prometheus | http://localhost:9090 | Metrics collection & alerting |
| Grafana | http://localhost:3001 | Dashboards & visualization |
| Node Exporter | http://localhost:9100 | Host system metrics |
| cAdvisor | http://localhost:8080 | Container metrics |

### Dashboards

- **Application Dashboard** — App up/down, CPU, memory, network I/O
- **Alerts** — AppDown, HighCPU, HighMemory, HighResponseTime

### Alert Rules

| Alert | Condition | Severity |
|---|---|---|
| AppDown | App unreachable for 1m | Critical |
| HighCPUUsage | CPU > 80% for 5m | Warning |
| HighMemoryUsage | Memory > 85% for 5m | Warning |
| HighResponseTime | p95 > 2s for 5m | Warning |

---

## Security (DevSecOps)

### Implemented Security Measures (3+ required)

1. **Docker Image Scanning** — Trivy scans images in CI pipeline for CVEs
2. **Filesystem/Dependency Scanning** — Trivy scans app dependencies for known vulnerabilities
3. **Secrets Management** — Kubernetes Secrets (base64), no hardcoded secrets in code
4. **Secure CI/CD** — GitHub Secrets for credentials, no plaintext tokens in pipeline
5. **Non-root Container** — App runs as `nextjs` user (UID 1001), not root
6. **HTTPS via Ingress** — TLS termination with cert-manager (production)
7. **Resource Limits** — CPU/memory limits prevent resource exhaustion

### Run local security scan

```bash
# Scan built image
make trivy-scan

# Scan source code
make trivy-fs
```

---

## Disaster Recovery

### Container/Node Failure Recovery

- **Kubernetes self-healing:** If a pod crashes, the Deployment controller automatically restarts it
- **Multiple replicas (prod):** 2 pods across nodes — one failing doesn't cause downtime
- **Health checks:** Liveness and readiness probes detect and restart unhealthy pods
- **Node failure:** EKS auto-scales and redistributes pods to healthy nodes

### Infrastructure Redeployment

```bash
# Full infrastructure can be reproduced from IaC:
make tf-init
make tf-apply-prod

# This recreates: VPC, EKS cluster, ECR, security groups, node groups
```

### Rollback Strategy

```bash
# Kubernetes rollback to previous deployment
kubectl rollout undo deployment/reddit-clone -n reddit-clone-prod

# View rollout history
kubectl rollout history deployment/reddit-clone -n reddit-clone-prod

# Rollback to specific revision
kubectl rollout undo deployment/reddit-clone -n reddit-clone-prod --to-revision=2
```

### Backup Strategy

| Component | Backup Method | Frequency |
|---|---|---|
| Application state | Firebase (managed, auto-backup) | Continuous |
| K8s manifests | Git repository (versioned) | Every commit |
| Terraform state | S3 bucket with versioning + DynamoDB lock | Every apply |
| Docker images | GHCR (tagged by SHA + branch) | Every build |
| Monitoring data | Prometheus TSDB (15-day retention) | Continuous |

### Recovery Time Objectives

- **Container restart:** ~30 seconds (liveness probe + restart)
- **Full redeployment from Git:** ~5 minutes (CI/CD pipeline)
- **Infrastructure from scratch:** ~15 minutes (Terraform apply)

---

## Quick Reference

```bash
make help          # Show all available commands
make dev           # Run dev locally
make test          # Run tests
make build         # Build Docker image
make trivy-scan    # Security scan
make monitoring    # Start Prometheus + Grafana
make k8s-dev       # Deploy to K8s dev
make k8s-prod      # Deploy to K8s prod
make tf-apply-dev  # Provision dev infra
```

---

## Author

**Durrell Gemuh** — DevOps & Cloud Infrastructure Engineer

- Website: https://durrellgemuh.com
- GitHub: [@durrello](https://github.com/durrello)


---

<div align="center">

### Built by

**Durrell Gemuh** - Founder @ NextGen Playground | DevOps & Cloud Infrastructure Engineer | AWS Community Builder

[![Portfolio](https://img.shields.io/badge/Portfolio-durrellgemuh.com-000?style=flat-square&logo=vercel)](https://durrellgemuh.com)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-durrello-0A66C2?style=flat-square&logo=linkedin)](https://www.linkedin.com/in/durrello/)
[![Dev.to](https://img.shields.io/badge/Dev.to-durrello-0A0A0A?style=flat-square&logo=devdotto)](https://dev.to/durrello)
[![X](https://img.shields.io/badge/X-@durrelloo-000?style=flat-square&logo=x)](https://x.com/durrelloo)
[![GitHub](https://img.shields.io/badge/GitHub-durrello-181717?style=flat-square&logo=github)](https://github.com/durrello)
[![Email](https://img.shields.io/badge/Email-durrell.gemuh.a@gmail.com-EA4335?style=flat-square&logo=gmail)](mailto:durrell.gemuh.a@gmail.com)

---

⭐ **Star this repo** if you found it useful - it helps others discover it!

</div>
