# ☁️ CloudForge — Production-Ready Full Stack Ecommerce Platform

> **Enterprise-grade microservices platform** with a complete DevOps pipeline: React frontend, Spring Boot microservices, AWS EKS deployment, Terraform IaC, GitHub Actions CI/CD, Helm charts, Prometheus/Grafana monitoring, and disaster recovery.

---

## 📋 Table of Contents

1. [Project Overview](#-project-overview)
2. [Architecture](#-architecture)
3. [Technology Stack](#-technology-stack)
4. [Project Structure](#-project-structure)
5. [Microservices](#-microservices)
6. [Infrastructure as Code](#-infrastructure-as-code-terraform)
7. [CI/CD Pipeline](#-cicd-pipeline)
8. [Kubernetes Deployment](#-kubernetes-deployment-helm)
9. [Monitoring & Observability](#-monitoring--observability)
10. [Security](#-security)
11. [Auto-Scaling](#-auto-scaling)
12. [Database Management](#-database-management)
13. [Disaster Recovery](#-disaster-recovery)
14. [Local Development Setup](#-local-development-setup)
15. [Environment Configuration](#-environment-configuration)
16. [Deployment Guide](#-deployment-guide)
17. [API Reference](#-api-reference)
18. [Cost Breakdown](#-cost-breakdown)
19. [Runbooks](#-runbooks)
20. [Contributing](#-contributing)

---

## 🎯 Project Overview

**CloudForge** is a production-ready, cloud-native ecommerce platform built to demonstrate enterprise-grade DevOps engineering. It encompasses:

- A **React.js** single-page application frontend
- **5 Spring Boot microservices** deployed as independent containers
- **Full AWS infrastructure** provisioned with Terraform (EKS, RDS, ElastiCache, CloudFront, S3, Route53, ALB)
- **Kubernetes orchestration** via Helm charts with auto-scaling, pod disruption budgets, and network policies
- **Multi-stage CI/CD** with GitHub Actions including canary deployments and automatic rollback
- **Full observability** with Prometheus, Grafana, Loki, and Alertmanager
- **Security-first design** with Trivy scanning, OWASP checks, Vault secrets management, and network policies

### Key Metrics at a Glance

| Metric | Value |
|---|---|
| Target Availability | 99.95% |
| P95 Latency Target | < 500ms |
| Recovery Time Objective (RTO) | 30 minutes |
| Recovery Point Objective (RPO) | 15 minutes |
| Container Images | 6 (1 frontend + 5 backend) |
| Terraform Modules | 5 (vpc, eks, rds, redis, networking) |
| GitHub Actions Workflows | 3 (ci-cd, security-scan, infrastructure) |
| Prometheus Alert Rules | 9 rules across 3 groups |

---

## 🏗️ Architecture

### High-Level Architecture

```
                        ┌──────────────────────────────────────────┐
                        │           Internet / Users                │
                        └───────────────┬──────────────────────────┘
                                        │ HTTPS
                        ┌───────────────▼──────────────────────────┐
                        │       AWS CloudFront CDN                  │
                        │   (Static assets + Edge caching)          │
                        └───────────────┬──────────────────────────┘
                                        │
                        ┌───────────────▼──────────────────────────┐
                        │     Application Load Balancer (ALB)       │
                        │         (Public Subnets - 3 AZs)          │
                        └───────────────┬──────────────────────────┘
                                        │
                        ┌───────────────▼──────────────────────────┐
                        │    NGINX Ingress Controller               │
                        │       (EKS — Private Subnets)             │
                        └────┬────────┬────────┬────────┬──────────┘
                             │        │        │        │
              ┌──────────────▼─┐  ┌───▼──┐  ┌─▼────┐  └──► (more services)
              │   React SPA    │  │  API │  │ Other│
              │  (frontend:    │  │  GW  │  │Routes│
              │   port 3000)   │  │ 8080 │  └──────┘
              └────────────────┘  └──┬───┘
                                     │ Routes to:
              ┌──────────────────────┼──────────────────────────────┐
              │                      │                              │
       ┌──────▼──────┐  ┌────────────▼──┐  ┌──────────┐  ┌────────▼──────┐
       │   Product   │  │    Order      │  │   User   │  │   Payment     │
       │   Service   │  │   Service     │  │  Service │  │   Service     │
       │  :8080      │  │   :8080       │  │  :8080   │  │   :8080       │
       └──────┬──────┘  └───────┬───────┘  └────┬─────┘  └────────┬──────┘
              │                 │               │                   │
              └─────────────────┴───────────────┴───────────────────┘
                                        │
                 ┌──────────────────────┴───────────────────────┐
                 │              Data Tier (Isolated Subnets)     │
                 │                                               │
                 │  ┌──────────────────┐  ┌───────────────────┐ │
                 │  │  RDS PostgreSQL  │  │  ElastiCache Redis │ │
                 │  │  (Multi-AZ)      │  │  (2 nodes, HA)     │ │
                 │  └──────────────────┘  └───────────────────┘ │
                 └───────────────────────────────────────────────┘

                 ┌───────────────────────────────────────────────┐
                 │           Monitoring Namespace                 │
                 │  Prometheus · Grafana · Loki · Alertmanager   │
                 └───────────────────────────────────────────────┘
```

### Network Architecture

```
VPC: 10.0.0.0/16  (us-east-1)
│
├── Public Subnets (ALB, NAT Gateways, Bastion)
│   ├── us-east-1a  10.0.1.0/24
│   ├── us-east-1b  10.0.2.0/24
│   └── us-east-1c  10.0.3.0/24
│
├── Private Subnets (EKS Worker Nodes & Pods)
│   ├── us-east-1a  10.0.101.0/24
│   ├── us-east-1b  10.0.102.0/24
│   └── us-east-1c  10.0.103.0/24
│
└── Database Subnets (RDS, ElastiCache — isolated)
    ├── us-east-1a  10.0.201.0/24
    ├── us-east-1b  10.0.202.0/24
    └── us-east-1c  10.0.203.0/24
```

### CI/CD Pipeline Flow

```
  Code Push
      │
      ▼
  ┌─────────────────────┐
  │  Quality Gates       │  ← ESLint, Maven Checkstyle, JUnit, Jest
  └──────────┬──────────┘
             │ pass
             ▼
  ┌─────────────────────┐
  │  Security Scan       │  ← OWASP, Trivy FS scan, Gitleaks
  └──────────┬──────────┘
             │ pass
             ▼
  ┌─────────────────────┐
  │  Build & Push        │  ← Docker Buildx (multi-arch), GHCR push
  └──────────┬──────────┘
             │
      ┌──────┴──────────┐
      │                 │
  develop             main
      │                 │
      ▼                 ▼
  Deploy Dev       Canary (10%)
  Deploy Staging   ↓ monitor 5m
                   Full Production
                   ↓ if fail →
                   Auto Rollback
```

---

## 🛠️ Technology Stack

### Frontend
| Technology | Version | Purpose |
|---|---|---|
| React.js | 18.2 | UI framework |
| Node.js | 20 LTS | Runtime |
| ESLint | 8.x | Code linting |

### Backend (Microservices)
| Technology | Version | Purpose |
|---|---|---|
| Spring Boot | 3.1.5 | Microservice framework |
| Spring Cloud Gateway | 2022.0.4 | API gateway & routing |
| Java | 17 (Temurin LTS) | Language runtime |
| Micrometer + Prometheus | latest | Metrics export |
| Maven | 3.9+ | Build tool |
| JaCoCo | 0.8.10 | Code coverage |

### Infrastructure
| Technology | Version | Purpose |
|---|---|---|
| Terraform | ≥ 1.5.0 | Infrastructure as Code |
| AWS EKS | 1.27 | Managed Kubernetes |
| AWS RDS PostgreSQL | 15.3 | Managed relational database |
| AWS ElastiCache Redis | 7.0 | In-memory caching |
| AWS ALB | — | Layer-7 load balancer |
| AWS CloudFront | — | Global CDN |
| AWS S3 | — | Object storage (logs, backups) |
| AWS Route53 | — | DNS & health checks |

### Kubernetes & Deployment
| Technology | Purpose |
|---|---|
| Kubernetes | Container orchestration |
| Helm 3 | Package management for K8s manifests |
| NGINX Ingress | Ingress controller |
| cert-manager | Automatic TLS via Let's Encrypt |
| HPA (Horizontal Pod Autoscaler) | CPU/memory-based pod scaling |
| PodDisruptionBudget | High-availability during maintenance |
| NetworkPolicy | Zero-trust pod-level firewall |

### Observability
| Technology | Purpose |
|---|---|
| Prometheus | Metrics collection & alerting rules |
| Grafana | Dashboards & visualization |
| Loki | Log aggregation (S3-backed) |
| Alertmanager | Alert routing (Slack, PagerDuty, Email) |

### CI/CD & Security
| Technology | Purpose |
|---|---|
| GitHub Actions | CI/CD pipeline automation |
| Docker Buildx | Multi-platform image builds |
| GHCR (GitHub Container Registry) | Container image storage |
| Trivy | Container & filesystem CVE scanning |
| OWASP Dependency-Check | Dependency vulnerability analysis |
| Gitleaks | Secret detection in git history |
| tfsec | Terraform security scanning |
| HashiCorp Vault | Secrets management |

---

## 📁 Project Structure

```
CloudForge/
│
├── .github/
│   └── workflows/
│       ├── ci-cd.yml              # Main pipeline: test → build → deploy (canary)
│       ├── security-scan.yml      # Weekly security scans (Trivy, Gitleaks, tfsec)
│       └── infrastructure.yml     # Manual Terraform plan/apply/destroy
│
├── backend/
│   ├── pom.xml                    # Maven parent POM (all services inherit)
│   ├── api-gateway/               # Spring Cloud Gateway — routes all /api/* traffic
│   │   ├── Dockerfile
│   │   ├── pom.xml
│   │   └── src/
│   ├── product-service/           # Product catalog & inventory REST API
│   │   ├── Dockerfile
│   │   ├── pom.xml
│   │   └── src/
│   ├── order-service/             # Order creation & management REST API
│   │   ├── Dockerfile
│   │   ├── pom.xml
│   │   └── src/
│   ├── user-service/              # User profile & authentication REST API
│   │   ├── Dockerfile
│   │   ├── pom.xml
│   │   └── src/
│   └── payment-service/           # Payment processing REST API
│       ├── Dockerfile
│       ├── pom.xml
│       └── src/
│
├── frontend/
│   ├── package.json               # NPM config, scripts, dependencies
│   └── .eslintrc.json             # ESLint rules
│
├── infrastructure/
│   ├── terraform/
│   │   ├── main.tf                # Root module: composes VPC, EKS, RDS, Redis, CDN
│   │   ├── variables.tf           # All configurable input variables
│   │   ├── outputs.tf             # Exported values (endpoints, IDs)
│   │   ├── terraform.tfvars.example
│   │   ├── modules/
│   │   │   ├── vpc/               # VPC, subnets, NAT gateways, route tables
│   │   │   ├── eks/               # EKS cluster, OIDC, node groups (on-demand + spot)
│   │   │   ├── rds/               # RDS PostgreSQL 15, parameter group, monitoring
│   │   │   ├── redis/             # ElastiCache Redis 7, replication group
│   │   │   └── networking/        # ALB, security groups, Route53 records
│   │   └── environments/
│   │       ├── dev/               # Minimal resources, single NAT, no Multi-AZ
│   │       ├── staging/           # Mid-size, Let's Encrypt staging
│   │       └── prod/              # Full HA, Multi-AZ, S3 remote state
│   │
│   └── kubernetes/
│       ├── base/
│       │   ├── namespaces/        # K8s namespace definitions
│       │   └── configs/           # Network policies (zero-trust)
│       └── helm/
│           └── ecommerce/         # Umbrella Helm chart for all services
│               ├── Chart.yaml
│               ├── values.yaml            # Production defaults
│               ├── values-dev.yaml
│               ├── values-staging.yaml
│               ├── values-prod.yaml
│               └── templates/
│                   ├── _helpers.tpl       # Shared label & naming helpers
│                   ├── frontend.yaml      # Deployment + Service for React SPA
│                   ├── backend-services.yaml  # Deployments + Services for 5 microservices
│                   ├── ingress.yaml       # NGINX ingress with TLS termination
│                   ├── hpa.yaml           # HPA for all 6 workloads
│                   └── pdb.yaml           # PodDisruptionBudget for HA
│
├── monitoring/
│   ├── prometheus/
│   │   ├── prometheus.yml         # Scrape config: K8s pods, nodes, exporters
│   │   └── rules/
│   │       └── alerts.yaml        # Alert rules: error rate, latency, SLO, infra
│   ├── alertmanager/
│   │   └── alertmanager.yml       # Routing: Slack, PagerDuty, email, inhibit rules
│   ├── loki/
│   │   └── loki-config.yaml       # S3-backed log aggregation, 30-day retention
│   └── grafana/
│       └── datasources/
│           └── datasources.yaml   # Auto-provisioned: Prometheus, Loki, Tempo
│
└── ReadMe.md                      # This file
```

---

## 🔬 Microservices

### Service Map

| Service | Port | Responsibility | Endpoints |
|---|---|---|---|
| **api-gateway** | 8080 | Route all `/api/*` to downstream services | All `/api/**` |
| **product-service** | 8080 | Product catalog, inventory | `GET /api/products`, `GET /api/products/{id}` |
| **order-service** | 8080 | Order creation & retrieval | `GET /api/orders`, `POST /api/orders` |
| **user-service** | 8080 | User profiles & auth | `GET /api/users/me` |
| **payment-service** | 8080 | Payment processing & verification | `POST /api/payments/process`, `GET /api/payments/verify/{id}` |

### Shared Service Contract

Every microservice exposes these actuator endpoints for the platform:

```
GET /actuator/health           → Aggregated health status
GET /actuator/health/liveness  → Kubernetes liveness probe target
GET /actuator/health/readiness → Kubernetes readiness probe target
GET /actuator/prometheus       → Prometheus metrics scrape endpoint
GET /actuator/info             → Application metadata
```

### Inter-Service Communication

```
Client → CloudFront → ALB → NGINX Ingress → API Gateway → [Backend Service]
                                           │
                             ┌─────────────┼──────────────┐
                             │             │              │
                        product-svc   order-svc      user-svc
```

All inter-service traffic stays within the Kubernetes cluster. The API Gateway performs path-based routing using Spring Cloud Gateway route predicates.

---

## 🌍 Infrastructure as Code (Terraform)

### Module Breakdown

#### `modules/vpc`
Provisions the network foundation:
- Custom VPC (`10.0.0.0/16`) with DNS enabled
- **Public subnets** (3 AZs) — for ALB and NAT gateways
- **Private subnets** (3 AZs) — for EKS worker nodes and pods
- **Database subnets** (3 AZs) — isolated tier for RDS and Redis
- NAT Gateways (1 per AZ in production, 1 shared in dev/staging)
- Route tables and associations
- Default security group allowing intra-VPC communication

#### `modules/eks`
Provisions the Kubernetes cluster:
- EKS control plane with all log types enabled (api, audit, authenticator, controllerManager, scheduler)
- OIDC provider for IAM Roles for Service Accounts (IRSA)
- **On-demand node group**: `t3.medium`, 2–5 nodes
- **Spot node group**: `t3.medium / t3a.medium / t2.medium`, 1–10 nodes (tainted: `spot=true:NoSchedule`)
- Cluster Autoscaler tags on node groups

#### `modules/rds`
Provisions the database:
- PostgreSQL 15.3, `gp3` storage, Multi-AZ (production)
- Performance Insights enabled (7-day retention)
- Enhanced monitoring via IAM role (60s interval)
- Automated daily backups (30-day retention, production)
- DB parameter group with `pg_stat_statements` enabled
- Storage auto-scaling: 100 GB → 500 GB

#### `modules/redis`
Provisions the cache layer:
- ElastiCache Redis 7.0 Replication Group
- Automatic failover and Multi-AZ enabled (production)
- Encryption at rest enabled
- Dedicated security group (port 6379 from app SG only)
- Daily snapshots, 7-day retention

#### `modules/networking`
Provisions load balancing and DNS:
- Application Load Balancer (internet-facing, public subnets)
- HTTP → HTTPS redirect listener
- HTTPS listener with ACM certificate (SNI)
- Target group with `/healthz` health check
- Route53 A records for `app.*`, `api.*`, `metrics.*`
- Route53 health check for DR failover

### Deploying Infrastructure

```bash
# 1. Initialise Terraform for the target environment
cd infrastructure/terraform/environments/prod
terraform init

# 2. Preview planned changes
terraform plan -var="database_password=<secret>"

# 3. Apply (requires manual approval in GitHub Actions for prod)
terraform apply -var="database_password=<secret>"

# 4. View all outputs (endpoints, cluster IDs, bucket names)
terraform output
```

> **Remote State**: Production state is stored in S3 (`ecommerce-terraform-state`) with DynamoDB state locking (`terraform-lock`). Create these resources manually before the first `terraform init`.

---

## 🔄 CI/CD Pipeline

### Workflow: `ci-cd.yml`

Triggered on every push to `main` or `develop`, and on pull requests.

#### Stage 1 — Quality Gates
- **Backend**: Maven clean verify, JUnit tests, JaCoCo coverage
- **Frontend**: `npm ci`, ESLint lint check, Jest unit tests
- Artifacts: JUnit XML reports uploaded for review

#### Stage 2 — Security Scan
- **OWASP Dependency-Check**: scans `pom.xml` and `package.json`; fails on CVSS ≥ 9
- **Trivy FS scan**: scans entire repository for HIGH/CRITICAL CVEs
- Results uploaded to GitHub Security tab as SARIF

#### Stage 3 — Build & Push
- Docker Buildx multi-platform builds for all 6 container images
- Images pushed to **GitHub Container Registry (GHCR)**
- Tags: `{branch}-{short-sha}`, `latest`, semver when tagged
- Post-push Trivy scan on the built frontend image

#### Stage 4 — Deploy Dev / Staging (`develop` branch)
- Helm upgrade/install to `dev` and `staging` namespaces
- Automatic, no manual approval required
- Runs smoke test script after deployment

#### Stage 5 — Canary Deploy to Production (`main` branch)
- Requires **manual approval** via GitHub environment protection
- Deploys 1 canary replica with `canary.enabled=true`
- Monitors for 5 minutes via `monitor-canary.sh`
- Promotes to full deployment if healthy
- Sends Slack notification on success

#### Stage 6 — Auto Rollback
- Triggered automatically if production deploy fails
- Runs `helm rollback ecommerce 0` to previous release
- Sends Slack rollback alert

### Required GitHub Secrets

| Secret | Description |
|---|---|
| `AWS_ACCESS_KEY_ID` | IAM access key with EKS deploy permissions |
| `AWS_SECRET_ACCESS_KEY` | IAM secret for the above key |
| `SLACK_WEBHOOK_URL` | Incoming webhook URL for deployment notifications |
| `PAGERDUTY_SERVICE_KEY` | PagerDuty integration key for critical alerts |
| `SONAR_TOKEN` | SonarQube authentication token |
| `SONAR_HOST_URL` | SonarQube server URL |

---

## ☸️ Kubernetes Deployment (Helm)

### Umbrella Chart: `infrastructure/kubernetes/helm/ecommerce`

The single chart manages all application workloads. Configuration is split per environment via value override files.

```bash
# Install to production
helm upgrade --install ecommerce ./infrastructure/kubernetes/helm/ecommerce \
  --namespace production \
  --set global.imageTag=<SHA> \
  --values values-prod.yaml \
  --wait --timeout 10m

# Check deployment status
helm status ecommerce -n production

# Roll back to previous release
helm rollback ecommerce 0 -n production

# View history
helm history ecommerce -n production
```

### Template Overview

| Template | Resources Created |
|---|---|
| `frontend.yaml` | Deployment + Service for React SPA |
| `backend-services.yaml` | Deployment + Service × 5 microservices |
| `ingress.yaml` | NGINX Ingress with TLS, host-based routing |
| `hpa.yaml` | HorizontalPodAutoscaler × 6 workloads |
| `pdb.yaml` | PodDisruptionBudget × 6 workloads |

### Resource Limits (Production Default)

| Workload | CPU Request | CPU Limit | Memory Request | Memory Limit |
|---|---|---|---|---|
| frontend | 250m | 500m | 256Mi | 512Mi |
| api-gateway | 250m | 500m | 256Mi | 512Mi |
| product-service | 200m | 400m | 256Mi | 512Mi |
| order-service | 200m | 400m | 256Mi | 512Mi |
| user-service | 200m | 400m | 256Mi | 512Mi |
| payment-service | 250m | 500m | 256Mi | 512Mi |

### Kubernetes Namespaces

| Namespace | Purpose |
|---|---|
| `production` | Live production workloads |
| `staging` | Pre-production verification |
| `dev` | Development & feature branch testing |
| `monitoring` | Prometheus, Grafana, Loki, Alertmanager |
| `ingress-nginx` | NGINX Ingress controller |
| `cert-manager` | Let's Encrypt TLS automation |
| `vault` | HashiCorp Vault secrets management |

---

## 📊 Monitoring & Observability

### Prometheus

Scrapes metrics from:
- All Spring Boot services via `/actuator/prometheus` (pod annotation auto-discovery)
- Kubernetes nodes via Node Exporter
- Kubernetes state via kube-state-metrics
- PostgreSQL via postgres-exporter
- Redis via redis-exporter
- Prometheus itself

Retention: **15 days**, scrape interval: **15 seconds**

### Alert Rules

| Alert | Condition | Severity |
|---|---|---|
| `ServiceHighErrorRate` | HTTP 5xx rate > 5% for 2 min | critical |
| `ServiceHighLatency` | P95 latency > 1s for 5 min | warning |
| `PodCrashLooping` | Restart rate > 0 for 2 min | critical |
| `DeploymentReplicasMismatch` | Available < Desired for 5 min | warning |
| `NodeHighCPU` | CPU > 85% for 10 min | warning |
| `NodeDiskPressure` | Disk < 15% free for 5 min | critical |
| `DatabaseConnectionPoolExhausted` | Pool > 90% for 3 min | critical |
| `RedisHighMemoryUsage` | Memory > 85% for 5 min | warning |
| `SLOAvailabilityBreached` | Availability < 99.9% over 1h | critical |

### Alertmanager Routing

```
All Alerts
   ├── severity=critical → PagerDuty + #alerts-critical (Slack)
   ├── severity=warning  → #alerts-warnings (Slack)
   ├── team=database     → DBA email
   └── team=oncall       → PagerDuty
```

### Grafana Dashboards

Pre-provisioned via `datasources.yaml`. Recommended dashboards to import:

| Dashboard | Grafana ID | Purpose |
|---|---|---|
| Kubernetes Cluster Overview | 7249 | Node, pod, namespace health |
| Spring Boot Statistics | 12685 | JVM metrics, request rates |
| PostgreSQL Overview | 9628 | Query performance, connections |
| Redis Overview | 763 | Memory, hit rate, latency |
| NGINX Ingress | 9614 | Request rate, error rate, latency |

### Loki (Log Aggregation)

- Logs aggregated from all pods via Promtail DaemonSet
- Stored in S3 for durability (30-day retention)
- Query logs in Grafana Explore panel using LogQL:

```logql
# All errors from the order service in the last hour
{namespace="production", app="order-service"} |= "ERROR" | logfmt

# Request latency from the API gateway
{app="api-gateway"} | pattern `<ip> - - [<_>] "<method> <path> <_>" <status> <bytes> "<_>" "<_>" <latency>ms`
```

---

## 🔒 Security

### Container Security
- All images run as **non-root** (`UID 1000`)
- **Read-only root filesystem** enforced via `securityContext`
- All Linux capabilities dropped (`drop: [ALL]`)
- Privilege escalation blocked (`allowPrivilegeEscalation: false`)
- Multi-stage Dockerfiles — no build tools in final image

### Network Security
- **Default deny-all** NetworkPolicy in `production` namespace
- Explicit allow rules for each permitted traffic path:
  - Ingress controller → frontend / api-gateway only
  - API gateway → backend services only
  - Monitoring namespace → all pods (port 8080 only)
  - All pods → DNS (port 53)
- Database subnets not reachable from pods directly

### Secret Management
- Secrets stored in **HashiCorp Vault** (not in K8s secrets or env vars)
- **External Secrets Operator** syncs Vault secrets into K8s Secrets
- Kubernetes Secrets encrypted at rest (EKS encryption config)
- No secrets committed to Git — enforced by Gitleaks in CI

### TLS/SSL
- Let's Encrypt production certificates via cert-manager
- Automatic renewal before expiry
- TLS 1.2+ enforced (TLS 1.3 preferred)
- HTTP → HTTPS forced redirect at ALB and NGINX Ingress

### CI/CD Security Gates
- OWASP Dependency-Check (fail on CVSS ≥ 9)
- Trivy filesystem scan (fail on CRITICAL)
- Trivy container scan after build (fail on CRITICAL)
- tfsec infrastructure scan (soft-fail, review required)
- Gitleaks secret detection on full git history

---

## 📈 Auto-Scaling

### Horizontal Pod Autoscaler (HPA)

Applied to all 6 workloads. Scale-up is aggressive; scale-down is conservative to avoid flapping.

```yaml
minReplicas: 2        # Always at least 2 for HA
maxReplicas: 15       # Hard ceiling per service
targetCPU: 70%        # Scale up when avg CPU > 70%
targetMemory: 80%     # Scale up when avg memory > 80%

scaleDown:
  stabilizationWindow: 300s   # Wait 5 minutes before scaling down
  maxDecrease: 25% per minute # Gradual scale-down

scaleUp:
  stabilizationWindow: 30s    # React quickly to load
  maxIncrease: 100% per 30s   # Can double in 30 seconds
```

### Cluster Autoscaler

Configured via node group tags (`k8s.io/cluster-autoscaler/enabled=true`):
- **Scale up**: triggered when pods are `Pending` for > 30 seconds
- **Scale down**: triggered when node utilisation < 50% for > 10 minutes
- General node group: 2–5 on-demand `t3.medium` nodes
- Spot node group: 1–10 `t3.medium / t3a.medium / t2.medium` spot nodes

### Cost Optimisation via Spot Instances

Spot instances (node group `spot`) run stateless workloads and are tainted:
```
key=spot, value=true, effect=NoSchedule
```
Only pods with the matching toleration are scheduled on spot nodes, protecting critical workloads.

---

## 💾 Database Management

### PostgreSQL (RDS)

| Setting | Value |
|---|---|
| Engine | PostgreSQL 15.3 |
| Instance | `db.t3.medium` |
| Storage | 100 GB gp3 → auto-scales to 500 GB |
| Multi-AZ | Enabled (production) |
| Backups | Daily automated, 30-day retention |
| Backup window | 03:00–04:00 UTC |
| Maintenance | Sunday 04:00–05:00 UTC |
| Monitoring | Enhanced monitoring, 60s interval |
| Performance Insights | Enabled, 7-day retention |
| Extensions | `pg_stat_statements` (all queries tracked) |

### Connection Pooling

Each Spring Boot service uses **HikariCP** (default Spring Boot pool):
- Max pool size: 10 connections per pod instance
- Connection timeout: 30 seconds
- Idle timeout: 10 minutes
- Max lifetime: 30 minutes

### Redis (ElastiCache)

| Setting | Value |
|---|---|
| Engine | Redis 7.0 |
| Node type | `cache.t3.micro` |
| Nodes | 2 (1 primary + 1 replica) |
| Automatic failover | Enabled |
| Multi-AZ | Enabled |
| Snapshots | Daily, 7-day retention |
| Encryption at rest | Enabled |
| Eviction policy | `volatile-lru` |

---

## 🔁 Disaster Recovery

### Backup Strategy

| Data | Type | Frequency | Retention |
|---|---|---|---|
| PostgreSQL | Automated RDS snapshot | Daily | 30 days |
| PostgreSQL | Transaction logs | Continuous | 5 days (PITR) |
| Redis | ElastiCache snapshot | Daily | 7 days |
| Kubernetes state | Velero backup to S3 | Daily | 30 days |
| Application logs | S3 (Loki) | Continuous | 30 days |
| Infrastructure | Terraform state in S3 | On every apply | Versioned |
| Helm releases | Helm history | On every deploy | Last 10 releases |

### Recovery Objectives

| Objective | Target |
|---|---|
| **RTO** (Recovery Time Objective) | 30 minutes for critical services |
| **RPO** (Recovery Point Objective) | 15 minutes (continuous RDS PITR) |

### Multi-Region Failover

| Region | Role | Traffic |
|---|---|---|
| `us-east-1` | Primary | 100% (normal) |
| `us-west-2` | Standby | 0% (standby, activates on failover) |

Route53 health checks poll the primary ALB every 30 seconds. If 3 consecutive checks fail, DNS failover activates automatically and traffic shifts to `us-west-2`.

### Database Restore Procedure

```bash
# Restore RDS from a point in time
aws rds restore-db-instance-to-point-in-time \
  --source-db-instance-identifier ecommerce-prod \
  --target-db-instance-identifier ecommerce-prod-restored \
  --restore-time 2026-11-13T00:00:00Z \
  --region us-east-1

# Promote the restored instance
aws rds promote-read-replica \
  --db-instance-identifier ecommerce-prod-restored
```

---

## 💻 Local Development Setup

### Prerequisites

| Tool | Version | Install |
|---|---|---|
| Java | 17 | [Adoptium](https://adoptium.net) |
| Maven | 3.9+ | `brew install maven` |
| Node.js | 20 LTS | [nodejs.org](https://nodejs.org) |
| Docker Desktop | latest | [docker.com](https://docker.com) |
| kubectl | 1.27+ | `brew install kubectl` |
| Helm | 3.12+ | `brew install helm` |
| Terraform | 1.6+ | `brew install terraform` |

### Run Backend Services Locally

```bash
# Clone the repository
git clone https://github.com/your-org/cloudforge.git
cd cloudforge

# Build all backend services
cd backend
mvn clean package -DskipTests

# Run order-service (repeat for other services on different ports)
cd order-service
mvn spring-boot:run

# Services start on port 8080 by default
# Access: http://localhost:8080/api/orders
# Health: http://localhost:8080/actuator/health
# Metrics: http://localhost:8080/actuator/prometheus
```

### Run Frontend Locally

```bash
cd frontend
npm install
npm start

# App available at http://localhost:3000
```

### Run with Docker Compose (All Services)

```bash
# From project root
docker compose up --build

# Services available:
# Frontend:         http://localhost:3000
# API Gateway:      http://localhost:8080
# Product Service:  http://localhost:8081
# Order Service:    http://localhost:8082
# User Service:     http://localhost:8083
# Payment Service:  http://localhost:8084
```

### Run Tests

```bash
# Backend — all services
cd backend && mvn clean verify

# Backend — single service
cd backend/order-service && mvn test

# Frontend
cd frontend && npm test

# View coverage report (after mvn verify)
open backend/order-service/target/site/jacoco/index.html
```

---

## ⚙️ Environment Configuration

### Terraform Variables

Copy the example file and populate your values:

```bash
cp infrastructure/terraform/terraform.tfvars.example \
   infrastructure/terraform/environments/prod/terraform.tfvars

# Edit with your values:
# - aws_region
# - database_password
# - domain_name
# - route53_zone_id
```

### Application Environment Variables (Kubernetes)

Environment-specific values are injected via Helm values files. Sensitive values are sourced from Kubernetes Secrets (backed by Vault):

| Variable | Service | Source |
|---|---|---|
| `SPRING_PROFILES_ACTIVE` | All backend | Helm values |
| `SPRING_DATASOURCE_URL` | All backend | Vault Secret |
| `SPRING_DATASOURCE_PASSWORD` | All backend | Vault Secret |
| `SPRING_REDIS_HOST` | All backend | Vault Secret |
| `REACT_APP_API_URL` | Frontend | Helm values |
| `STRIPE_API_KEY` | payment-service | Vault Secret |

---

## 🚀 Deployment Guide

### First-Time Production Setup

```bash
# Step 1: Create Terraform remote state resources (one-time, manual)
aws s3 mb s3://ecommerce-terraform-state --region us-east-1
aws s3api put-bucket-versioning \
  --bucket ecommerce-terraform-state \
  --versioning-configuration Status=Enabled
aws dynamodb create-table \
  --table-name terraform-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST

# Step 2: Provision infrastructure
cd infrastructure/terraform/environments/prod
terraform init && terraform apply

# Step 3: Configure kubectl
aws eks update-kubeconfig --region us-east-1 --name ecommerce-prod

# Step 4: Install cluster prerequisites
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add cert-manager https://charts.jetstack.io
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

kubectl apply -f infrastructure/kubernetes/base/namespaces/namespaces.yaml

helm install ingress-nginx ingress-nginx/ingress-nginx -n ingress-nginx
helm install cert-manager cert-manager/cert-manager -n cert-manager \
  --set installCRDs=true

# Step 5: Deploy monitoring stack
helm install prometheus prometheus-community/kube-prometheus-stack \
  -n monitoring \
  -f monitoring/prometheus/prometheus.yml

# Step 6: Deploy application (or push to main branch to trigger CI/CD)
helm upgrade --install ecommerce ./infrastructure/kubernetes/helm/ecommerce \
  -n production \
  --set global.imageTag=latest \
  -f infrastructure/kubernetes/helm/ecommerce/values-prod.yaml
```

### Verifying a Deployment

```bash
# Check all pods are running
kubectl get pods -n production

# Check HPA status
kubectl get hpa -n production

# Check ingress
kubectl get ingress -n production

# Check service endpoints
kubectl get svc -n production

# Tail application logs
kubectl logs -f deployment/order-service -n production

# Check Helm release status
helm status ecommerce -n production
```

---

## 📡 API Reference

### Product Service

```
GET  /api/products          List all products
GET  /api/products/{id}     Get product by ID
```

**Response — GET /api/products**
```json
[
  {
    "id": "PROD-001",
    "name": "Production Kubernetes Guide",
    "description": "...",
    "price": 59.99,
    "category": "Books",
    "inStock": true,
    "stockQuantity": 150
  }
]
```

### Order Service

```
GET  /api/orders            List orders
POST /api/orders            Create a new order
```

**Request — POST /api/orders**
```json
{ "productId": "PROD-001", "quantity": 2, "userId": "USR-001" }
```

**Response**
```json
{ "orderId": "ORD-a3f2b1c4", "status": "CREATED", "productId": "PROD-001" }
```

### User Service

```
GET  /api/users/me          Get current user profile
```

**Response**
```json
{ "id": 1, "username": "devops_admin", "email": "admin@ecommerce.com", "role": "ROLE_ADMIN" }
```

### Payment Service

```
POST /api/payments/process          Process a payment
GET  /api/payments/verify/{txnId}   Verify transaction status
```

**Request — POST /api/payments/process**
```json
{ "orderId": "ORD-a3f2b1c4", "amount": 119.98, "method": "CREDIT_CARD" }
```

**Response**
```json
{
  "transactionId": "TXN-A3F2B1C4",
  "status": "SUCCESS",
  "amount": 119.98,
  "gateway": "STRIPE-MOCK-PROD",
  "timestamp": "Thu Nov 13 09:30:00 UTC 2026"
}
```

---

## 💰 Cost Breakdown

### Production Monthly Estimate

| Resource | Config | Monthly Cost |
|---|---|---|
| EKS Cluster (control plane) | Managed | ~\$73 |
| EC2 On-demand nodes (2× t3.medium) | 24/7 | ~\$120 |
| EC2 Spot nodes (avg 2× t3.medium) | 24/7 | ~\$40 |
| RDS PostgreSQL (db.t3.medium, Multi-AZ) | 100 GB gp3 | ~\$140 |
| ElastiCache Redis (2× cache.t3.micro) | Multi-AZ | ~\$50 |
| Application Load Balancer | Active, 1 LCU avg | ~\$25 |
| CloudFront | 1 TB/month transfer | ~\$85 |
| S3 (logs, backups, Loki) | ~500 GB | ~\$12 |
| NAT Gateways (3× for HA) | 100 GB/month | ~\$105 |
| Route53 | Hosted zone + queries | ~\$5 |
| Data Transfer | Moderate usage | ~\$30 |
| **Total (estimated)** | | **~\$685/month** |

### Cost Optimisation Tips

1. **Spot instances** save ~60–70% on worker node compute costs
2. **Reserved Instances** for RDS (1-year) save ~40%
3. **S3 Intelligent Tiering** for logs/backups reduces storage costs ~30%
4. **CloudFront** reduces data transfer costs from ALB
5. **Single NAT Gateway** in dev/staging saves ~\$70/month per environment

---

## 📖 Runbooks

### High Error Rate

**Alert**: `ServiceHighErrorRate` — HTTP 5xx > 5%

```bash
# 1. Check pod status
kubectl get pods -n production -l app=<service-name>

# 2. Check recent logs for exceptions
kubectl logs -n production deployment/<service-name> --since=10m | grep -i error

# 3. Check HPA — are we under-scaled?
kubectl get hpa -n production

# 4. Check database connectivity
kubectl exec -it deployment/<service-name> -n production -- \
  curl http://localhost:8080/actuator/health

# 5. Roll back if recently deployed
helm rollback ecommerce -n production
```

### Pod Crash Loop

**Alert**: `PodCrashLooping`

```bash
# 1. Describe the pod for events and status
kubectl describe pod <pod-name> -n production

# 2. Check previous container logs (before crash)
kubectl logs <pod-name> -n production --previous

# 3. Check resource limits — OOMKilled?
kubectl get pod <pod-name> -n production -o jsonpath='{.status.containerStatuses[0].lastState}'
```

### Database Connection Exhaustion

**Alert**: `DatabaseConnectionPoolExhausted`

```bash
# 1. Check active connections in PostgreSQL
# (Via kubectl exec into a pod with psql available)
psql -U dbadmin -d ecommerce -c "SELECT count(*), state FROM pg_stat_activity GROUP BY state;"

# 2. Check HikariCP metrics in Prometheus
# Query: hikaricp_connections_active{application="order-service"}

# 3. Scale out the affected service to distribute load
kubectl scale deployment/order-service --replicas=5 -n production

# 4. Long-term: review connection pool settings in application.yml
```

---

## 🤝 Contributing

### Branch Strategy

| Branch | Purpose | Deploy Target |
|---|---|---|
| `feature/*` | New features | — (PR only) |
| `develop` | Integration branch | Dev + Staging (auto) |
| `main` | Production-ready code | Production (canary, manual approval) |

### Workflow

```bash
# 1. Create a feature branch
git checkout -b feature/add-inventory-service

# 2. Write code + tests
# 3. Ensure tests pass locally
mvn clean verify   # backend
npm test           # frontend

# 4. Push and open a Pull Request to develop
git push origin feature/add-inventory-service
# Open PR → review required → merge

# 5. CI/CD auto-deploys to dev + staging
# 6. Merge develop → main to trigger canary production deploy
```

### Coding Standards

- **Backend**: Google Java Style (enforced by Maven Checkstyle plugin)
- **Frontend**: ESLint with react-app rules
- **Terraform**: `terraform fmt` before commit
- **Kubernetes**: YAML linted with `yamllint`
- **Commits**: Conventional Commits format (`feat:`, `fix:`, `chore:`, `docs:`)

---

## 📜 License

This project is released under the [MIT License](LICENSE).

---

## 👨‍💻 Authors

**CloudForge DevOps Team**
- Architecture, Infrastructure, CI/CD pipeline
- Microservices implementation
- Monitoring & Observability stack

---

> _Built to demonstrate enterprise-grade full stack DevOps engineering — from Terraform IaC to Kubernetes HPA to Prometheus SLO alerting._

