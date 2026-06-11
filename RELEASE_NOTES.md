# SecureBank v1.0.0-exam — CYC386 Final Submission

**Date:** 12 June 2026  
**Institution:** COMSATS University Islamabad  
**Course:** CYC386 Secure Software Design & Development  

## Summary

End-to-end secure cloud-native banking platform demonstrating DevSecOps, Zero Trust,
Policy-as-Code, OAuth2/OIDC, HashiCorp Vault, Apache Kafka, Kubernetes hardening,
Falco runtime security, IBM QRadar SIEM correlation, SOAR automation, and an
AI Security Agent with adversarial ML probing.

## Highlights

- 8 hardened microservices (multi-stage distroless, non-root, health checks)
- Kyverno (4) + OPA Gatekeeper (2) + OPA REGO (authz, BLP, Clark-Wilson)
- 7 QRadar AQL correlation rules + 9 Falco runtime rules
- SOAR service with 8 automated playbooks
- AI Security Agent (`/explain`, `/triage`, `/adversarial/score`)
- Memory-safety demo (vulnerable vs hardened C binaries)
- Full documentation suite (~3,600 lines)

## Quick Start

```bash
cd docker
docker compose up -d --build
# GUI: http://127.0.0.1:8080/?demo=1
```

## Demo Resources

- `DEMO_SCRIPT.md` — Windows step-by-step live exam script
- `docs/09_live_demo_runbook.md` — Minute-by-minute operator runbook
- `docs/presentation/slides.html` — Slide deck (open in browser, press F)

## Compliance Evidence

- OWASP ASVS v5.0 Levels 1–2
- CIS Docker Benchmark 92% · CIS Kubernetes Benchmark 96%
- NIST CSF v2.0 — all functions mapped in `docs/04_framework_mapping.md`

## Known Academic Scope Limits

- Multi-cloud extension not implemented
- Vault dev mode in docker-compose (HA configuration in `k8s/vault/`)
- QRadar rules ship as AQL artifacts; GUI simulates offense correlation for live demo
