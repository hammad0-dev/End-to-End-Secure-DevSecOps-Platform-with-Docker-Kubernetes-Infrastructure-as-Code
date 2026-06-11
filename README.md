# SecureBank — End-to-End Secure Cloud-Native DevSecOps Platform

**Course:** CYC386 Secure Software Design & Development
**Institution:** COMSATS University Islamabad
**Semester:** Spring 2026
**Instructor:** Engr. Muhammad Ahmad Nawaz
**Project Type:** Lab Final Examination
**Demo Date:** 12 June 2026

---

## 1. Overview

**SecureBank** is a microservices-based, event-driven, cloud-native banking platform built with Python/FastAPI, designed from the ground up around **Zero Trust**, **Defense-in-Depth**, **Secure-by-Design**, and **DevSecOps** principles. It demonstrates compliance with **OWASP ASVS v5.0**, **NIST CSF**, **NIST SP 800-207**, **SABSA**, **ISO/IEC 27034**, **CSA CCM**, **MITRE ATT&CK**, and **CIS Benchmarks**.

The platform showcases:
- Hardened, multi-stage Docker images & Kubernetes orchestration with Policy-as-Code (Kyverno + OPA Gatekeeper)
- OAuth2/OIDC + JWT authentication with RBAC/ABAC and MFA
- Event-driven architecture using Apache Kafka with TLS + ACLs
- Secret management with HashiCorp Vault (dynamic secrets)
- TLS 1.3 in-transit, AES-256 at-rest, key rotation
- Runtime security with Falco, SIEM with IBM QRadar integration
- AI/ML anomaly detection on transactions, logs, and metrics
- Full DevSecOps CI/CD with SonarQube, CodeQL, Trivy, OWASP ZAP, gitleaks
- Terraform IaC + Vault for reproducible infrastructure

---

## 2. Repository Structure

```
.
├── README.md                          # This file
├── DEMO_SCRIPT.md                     # Step-by-step live exam demo (Windows)
├── COMPLETION_STATUS.md               # Rubric self-assessment & evidence map
├── docs/                              # Security & architecture documentation
│   ├── 01_SRD.md                      # Security Requirements Document (+ CSRF, BLP, Clark-Wilson)
│   ├── 02_threat_model.md             # STRIDE/PASTA/DREAD + MITRE ATT&CK mapping
│   ├── 03_architecture.md             # C4 model + SABSA + Zero Trust blueprint
│   ├── 04_framework_mapping.md        # OWASP ASVS, NIST CSF, ISO27034, CSA CCM, BLP, Clark-Wilson, Schema Registry
│   ├── 05_executive_report.md         # Executive-level report
│   ├── 06_red_blue_team.md            # Red/Blue Team playbook
│   ├── 07_api_pentest_report.md       # API pentesting report
│   ├── 08_compliance_report.md        # CIS Docker/K8s, NIST SP 800-53 compliance
│   ├── 09_live_demo_runbook.md        # Minute-by-minute live exam demo script
│   ├── diagrams/                      # Architecture & threat diagrams (mermaid)
│   └── presentation/                  # Marp slide deck (export to PDF/HTML/PPTX)
├── src/                               # Microservices source code
│   ├── shared/                        # Shared libs: auth, crypto, logging, models, schemas
│   │   └── schemas/                   # Avro schemas (Confluent Schema Registry)
│   ├── auth-service/                  # OAuth2/OIDC + JWT + MFA
│   ├── account-service/               # Account management
│   ├── transaction-service/           # Money transfers (Kafka producer)
│   ├── fraud-detection-service/       # ML fraud detection (Kafka consumer)
│   ├── notification-service/          # SMS/email notifications (Kafka consumer)
│   ├── api-gateway/                   # Rate limiting, WAF, request routing
│   ├── soar-service/                  # [BONUS] QRadar/Falco/ML → playbooks
│   ├── ai-security-agent/             # [BONUS] AI alert reasoner + adversarial-ML probe
│   ├── memory-safety-demo/            # CWE-121/134/190/416 vuln vs hardened binaries
│   └── frontend/                      # Polished banking SPA (vanilla JS + CSP)
├── docker/                            # Dockerfiles & build scripts
│   ├── auth-service.Dockerfile
│   ├── account-service.Dockerfile
│   ├── transaction-service.Dockerfile
│   ├── fraud-detection-service.Dockerfile
│   ├── notification-service.Dockerfile
│   ├── api-gateway.Dockerfile
│   ├── docker-compose.yml             # Local stack
│   ├── docker-compose.security.yml    # Adds Falco, Trivy, Vault
│   └── trivy-policy.yaml
├── k8s/                               # K8s manifests + Helm charts
│   ├── base/                          # Namespaces, RBAC, NetworkPolicies, PSS
│   ├── apps/                          # Per-service deployments & services
│   ├── policies/                      # Kyverno + OPA Gatekeeper constraints
│   ├── observability/                 # (see monitor/ + docker-compose.security.yml)
│   ├── kafka/                         # Strimzi Kafka with TLS
│   ├── vault/                         # HashiCorp Vault HA
│   └── helm/                          # Helm chart for the platform
├── iac/                               # Terraform IaC
│   ├── modules/
│   │   ├── kubernetes/
│   │   ├── vault/
│   │   ├── kafka/
│   │   └── monitoring/
│   ├── environments/
│   │   ├── dev/
│   │   └── prod/
│   └── main.tf
├── ci/                                # CI/CD pipelines
│   ├── .github/workflows/             # GitHub Actions
│   ├── jenkins/                       # Jenkinsfile
│   ├── sonar-project.properties
│   ├── codeql-config.yml
│   ├── zap-baseline.conf
│   └── pre-commit-config.yaml
├── monitor/                           # Observability + SIEM
│   ├── prometheus/
│   ├── grafana/dashboards/
│   ├── loki/
│   ├── falco/rules/
│   ├── qradar/                        # QRadar DSM, rules, log source extensions
│   └── ml/                            # AI/ML anomaly detection models & service
└── reports/                           # SAST/DAST/Pentest/CIS compliance reports
    ├── sast/
    ├── dast/
    ├── pentest/
    ├── cis-docker/
    └── cis-k8s/
```

---

## 3. Team Roles

| Role | Responsibilities |
|------|-----------------|
| **Lead Developer** | Secure coding (FastAPI, JWT, validation, memory safety), Docker images |
| **Security Analyst** | Threat modelling (STRIDE/PASTA), API pentesting, AI/ML, Red Team |
| **DevSecOps Engineer** | Kubernetes hardening, Terraform IaC, observability, QRadar, Blue Team |
| **Red/Blue Lead** | Attack scenarios, defense playbooks, incident response drills |

---

## 4. Quick Start — Local (docker-compose)

```bash
# 1. Initialize Vault & seed secrets
cd docker
./scripts/init-vault.sh

# 2. Generate TLS certs (mTLS between services)
./scripts/gen-certs.sh

# 3. Bring up the stack
docker-compose -f docker-compose.yml -f docker-compose.security.yml up -d --build

# 4. Verify
curl -k https://localhost:8443/health     # API Gateway
curl -k https://localhost:8443/auth/login # Auth Service via gateway

# 5. Tail logs (Loki/Grafana available at http://localhost:3000)
docker-compose logs -f api-gateway auth-service
```

Default demo user (created on first boot of `auth-service` if `DEMO_SEED=true`):
- username: `demo@securebank.local`
- password: `Change-Me-On-First-Login!` *(forced rotation on first login)*

---

## 5. Production — Kubernetes

```bash
# Provision infra
cd iac/environments/dev
terraform init && terraform apply

# Deploy platform (Helm)
helm upgrade --install securebank ./k8s/helm \
  -n securebank --create-namespace \
  --values ./k8s/helm/values-dev.yaml

# Apply Policy-as-Code
kubectl apply -f k8s/policies/kyverno/
kubectl apply -f k8s/policies/gatekeeper/

# Observability stack (Prometheus, Grafana, Loki, Falco)
kubectl apply -f monitor/prometheus/
kubectl apply -f monitor/grafana/
# Or use the local overlay: docker compose -f docker-compose.security.yml up -d
```

---

## 6. Security Frameworks Mapped

| Framework | Coverage |
|-----------|----------|
| **OWASP ASVS v5.0** | Levels 1–2 fully met; L3 partial (HSM-backed keys deferred) |
| **NIST CSF (v2.0)** | Identify, Protect, Detect, Respond, Recover all covered |
| **NIST SP 800-207** | Zero Trust — policy decision/enforcement points per service |
| **NIST SP 800-53 Rev.5** | AC, AU, SC, SI control families implemented |
| **SABSA** | Contextual → Logical → Physical architecture layers documented |
| **ISO/IEC 27034** | App security controls (ASC) mapped to OWASP ASVS |
| **CSA CCM v4** | DCS, IAM, LOG, CCM domain controls |
| **CIS Docker Benchmark 1.6** | All applicable host/daemon/image/container controls |
| **CIS K8s Benchmark 1.9** | Control plane, etcd, worker node, policy controls |
| **MITRE ATT&CK** | TTPs mapped to Falco rules + QRadar correlation rules |

See `docs/04_framework_mapping.md` for the full matrix.

---

## 6.5 Bonus Extensions Implemented (+15%)

| Extension | Where |
|-----------|-------|
| **AI Security Agent** | `src/ai-security-agent/` — `/explain`, `/triage`, `/review`, `/adversarial/score` |
| **Advanced QRadar** | 7 AQL correlation rules including `dns-exfiltration`, `jwt-anomaly`, `rbac-priv-esc`, `memory-corruption` |
| **SOAR** | `src/soar-service/` — 8 playbooks dispatched from QRadar/Falco/ML webhooks |
| **Adversarial ML** | `src/ai-security-agent/app/adversarial.py` — salami-slice probe + PSI drift, retrain trigger |

Multi-Cloud is the only listed bonus we explicitly did not pursue (out of scope for an academic lab).

## 7. Demonstration Flow (Red Team vs Blue Team)

1. **Recon & Enumeration** — gateway exposes only mTLS; recon attempts trigger Falco
2. **Authentication bypass attempts** — JWT tampering, replay → blocked + QRadar offense
3. **Injection attacks** — SQLi, XSS, SSRF → blocked by input validation + WAF
4. **Memory attacks** — buffer overflow simulation (`ctypes` demo) → caught by ASLR/canary
5. **Container escape attempt** — `cap_drop`, `read-only fs`, `runAsNonRoot` block escalation
6. **Lateral movement** — NetworkPolicies + OPA deny east-west traffic
7. **Privilege escalation** — RBAC + PSS reject privileged pods
8. **Data exfiltration** — egress NetworkPolicy + Falco "outbound to unknown" rule
9. **Fraud injection** — ML anomaly model detects out-of-pattern transactions
10. **Detection & Response** — QRadar offense → automated playbook → contain & rotate

---

## 8. Compliance & Reports

- `reports/sast/` — SonarQube + CodeQL latest results
- `reports/dast/` — OWASP ZAP baseline & full scan
- `reports/pentest/` — OWASP API Security Top 10 test results
- `reports/cis-docker/` — Docker Bench results
- `reports/cis-k8s/` — kube-bench results

---

## 9. References

- NIST SP 800-160 Vol. 1 & 2, 800-207, 800-53 Rev.5, CSF v2.0
- OWASP ASVS v5.0, OWASP API Security Top 10 (2023), SAMM v2
- ISO/IEC 27001:2022, ISO/IEC 27034
- SABSA Blue Book, CSA CCM v4
- CIS Docker Benchmark 1.6.0, CIS Kubernetes Benchmark 1.9.0
- MITRE ATT&CK for Enterprise v15

---

## 10. License & Academic Integrity

This codebase was developed exclusively for the CYC386 final lab examination at COMSATS University Islamabad, Spring 2026. Not for production use without further security review.
