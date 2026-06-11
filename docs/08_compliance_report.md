# Compliance Report — SecureBank

This document collects compliance evidence for CIS Docker, CIS Kubernetes, NIST SP 800-53 Rev.5, OWASP ASVS, and CSA CCM.

For full per-control evidence, see `reports/`.

---

## 1. CIS Docker Benchmark 1.6.0 — Summary

`reports/cis-docker/docker-bench-2026-05-17.log` is the raw output from `docker-bench-security`. Summary:

| Section | Pass | Warn | Info | N/A |
|---------|------|------|------|-----|
| 1 Host config | 11 | 2 | 1 | 4 |
| 2 Docker daemon config | 13 | 1 | 0 | 2 |
| 3 Docker daemon config files | 18 | 0 | 0 | 0 |
| 4 Container images & build | 12 | 0 | 0 | 0 |
| 5 Container runtime | 25 | 0 | 1 | 4 |
| 6 Docker security operations | 1 | 0 | 0 | 1 |
| 7 Docker swarm config | N/A — not using swarm | — | — | — |
| **Score** | **92%** | | | |

### Highlights
- 4.1 Container user: `USER 10001` set in every Dockerfile
- 4.5 Cosign signing: enforced by admission policy
- 4.6 Healthcheck: all images expose `HEALTHCHECK CMD`
- 5.x Runtime: see K8s SecurityContext below

## 2. CIS Kubernetes Benchmark 1.9.0 — Summary

`reports/cis-k8s/kube-bench-2026-05-17.json`:

| Section | Pass | Fail | Warn | Info |
|---------|------|------|------|------|
| 1 Master node | 41 | 0 | 3 | 2 |
| 2 etcd | 7 | 0 | 0 | 0 |
| 3 Control plane config | 6 | 0 | 0 | 0 |
| 4 Worker | 17 | 0 | 0 | 2 |
| 5 Policies (RBAC, NP, PSS) | 27 | 0 | 2 | 6 |
| **Pass rate** | **96%** | | | |

### Selected pass evidence

| Control | Result | Evidence |
|---------|--------|----------|
| 1.2.5 Use service-account-key | PASS | API server flag set |
| 1.2.16 PodSecurity admission enabled | PASS | `--enable-admission-plugins=NodeRestriction,PodSecurity,...` |
| 1.2.21 etcd encryption at rest | PASS | `EncryptionConfiguration` with `aescbc` |
| 3.2 etcd peer-auto-tls disabled | PASS | `--peer-auto-tls=false` |
| 4.1.1 kubelet anonymous-auth false | PASS | kubeadm default + verified |
| 5.1.x RBAC | PASS | Per-service `Role` + `RoleBinding` |
| 5.2.x Pod Security Standards | PASS | `restricted` enforced via label |
| 5.3.x Network Policies | PASS | default-deny + explicit allows |
| 5.7.x Sec Contexts | PASS | `runAsNonRoot`, `readOnlyRootFilesystem`, `allowPrivilegeEscalation: false` |

## 3. NIST SP 800-53 Rev.5 — Control Implementation

See `docs/04_framework_mapping.md` §3. Full control-by-control evidence (with `kubectl get/describe` outputs, policy bundles, and log excerpts) is available in `reports/nist-800-53/`.

## 4. ASVS v5.0 — Coverage

| Chapter | Level Targeted | Tests Run | Pass |
|---------|---------------|-----------|------|
| V1 Architecture | L2 | 14 | 14 |
| V2 Authentication | L2 | 23 | 23 |
| V3 Session | L2 | 11 | 11 |
| V4 Access Control | L2 | 12 | 12 |
| V5 Validation | L2 | 18 | 18 |
| V6 Cryptography | L2 | 9 | 9 (L3 deferred — HSM) |
| V7 Error Handling | L2 | 7 | 7 |
| V8 Data Protection | L2 | 10 | 10 |
| V9 Comms | L2 | 8 | 8 |
| V11 Business Logic | L2 | 9 | 9 |
| V13 API | L2 | 14 | 14 |
| V14 Config | L2 | 11 | 11 |

## 5. CSA CCM v4 — Coverage

37 controls evaluated across DCS, IAM, LOG, IVS, TVM, SEF, DSP, AIS. 35 fully met; 2 partial (DCS-04 around physical security — N/A for academic lab, compensated via cloud-provider attestation).

## 6. Vulnerability Status (as of retest 2026-05-17)

| Severity | Open | Closed |
|----------|------|--------|
| Critical | 0 | 12 |
| High | 0 | 18 |
| Medium | 2 | 9 |
| Low | 5 | 21 |
| Info | 12 | — |

## 7. Continuous Compliance Plan

- Daily kube-bench + docker-bench job → S3 bucket, alert on regression
- Weekly Trivy + pip-audit + npm-audit (frontend) cron
- Monthly threat-model refresh
- Quarterly DR drill + tabletop
- Annual external pentest
