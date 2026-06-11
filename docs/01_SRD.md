# Security Requirements Document (SRD)

**Project:** SecureBank Cloud-Native DevSecOps Platform
**Course:** CYC386 — Spring 2026
**Version:** 1.0
**Date:** 2026-05-18

---

## 1. Scope

This SRD captures the security requirements for SecureBank — a microservices banking platform — and maps them to **OWASP ASVS v5.0**, **NIST SP 800-53 Rev.5**, and **ISO/IEC 27034**.

## 2. Stakeholders

| Stakeholder | Concern |
|-------------|---------|
| End-user customers | Confidentiality of PII/financial data, transaction integrity |
| Bank operators | Availability, audit, fraud detection |
| Regulators | Compliance with NIST CSF, ISO 27001, PCI-style controls |
| Red Team | Validate posture |
| Blue Team / SOC | Detect & respond |

## 3. Functional Security Requirements

| ID | Requirement | ASVS Ref | Priority |
|----|-------------|----------|----------|
| FSR-01 | All authentication MUST use OAuth2.0 Authorization Code + PKCE flow with OIDC | V2, V3 | MUST |
| FSR-02 | JWT tokens MUST be signed (RS256/ES256), max lifetime 15 min, refresh ≤7 days | V3.2 | MUST |
| FSR-03 | MFA (TOTP) MUST be enforced for high-value transactions and admin roles | V2.7 | MUST |
| FSR-04 | RBAC + ABAC policies MUST be evaluated at every API request via OPA | V4 | MUST |
| FSR-05 | Sessions MUST be stored in Redis with TLS + AES-GCM encryption, idle timeout 15 min | V3.3 | MUST |
| FSR-06 | Password policy: min 12 chars, breach-check against HIBP, Argon2id hash | V2.1 | MUST |
| FSR-07 | All financial transactions MUST be signed with idempotency key + HMAC | V8 | MUST |
| FSR-08 | Account lockout: 5 failed attempts → 15 min lock + alert | V2.2 | MUST |
| FSR-09 | All admin actions MUST be 4-eyes (dual approval) | — | SHOULD |
| FSR-10 | Step-up authentication for transfer > 10,000 PKR | V2.8 | MUST |

## 4. Non-Functional Security Requirements

### 4.1 Confidentiality

| ID | Requirement | NIST 800-53 |
|----|-------------|-------------|
| NFR-C-01 | TLS 1.3 enforced for ALL service-to-service and ingress traffic | SC-8, SC-13 |
| NFR-C-02 | AES-256-GCM at rest for DB + Redis + Kafka topic data | SC-28 |
| NFR-C-03 | Secrets MUST come from HashiCorp Vault (dynamic where possible) | SC-12, IA-5 |
| NFR-C-04 | Key rotation ≤ 90 days, with versioning and old-key emergency revoke | SC-12(2) |
| NFR-C-05 | PII MUST be field-level encrypted (account #, CNIC, email) | SC-28(1) |

### 4.2 Integrity

| ID | Requirement |
|----|-------------|
| NFR-I-01 | Container images MUST be signed (Cosign) and signature verified at admission |
| NFR-I-02 | All Kafka messages carry HMAC-SHA256 signature; consumers verify before processing |
| NFR-I-03 | Audit log records are append-only, hash-chained per service |
| NFR-I-04 | Immutable infrastructure (Terraform state encrypted, locked) |

### 4.3 Availability

| ID | Requirement |
|----|-------------|
| NFR-A-01 | Each service ≥2 replicas with PodDisruptionBudget |
| NFR-A-02 | Rate limiting: 100 req/min unauthenticated, 1000 req/min authenticated |
| NFR-A-03 | Circuit breakers + retry-with-jitter on all upstream calls |
| NFR-A-04 | Kafka topics replication factor ≥3, min ISR=2 |

### 4.4 Auditability

| ID | Requirement |
|----|-------------|
| NFR-AU-01 | All security-relevant events logged in CEF/JSON to Loki + QRadar |
| NFR-AU-02 | Log retention: 90 days online, 1 year cold storage |
| NFR-AU-03 | No PII in logs (mask CNIC, account #, card #) |
| NFR-AU-04 | Distributed tracing via OpenTelemetry; trace IDs propagated end-to-end |

## 5. Secure Development Lifecycle Requirements (ISO/IEC 27034)

| ID | Requirement |
|----|-------------|
| SDLC-01 | Threat modelling (STRIDE) for every new feature; tracked in Threat Dragon |
| SDLC-02 | Pre-commit hooks: gitleaks, detect-secrets, ruff, bandit |
| SDLC-03 | SAST: SonarQube + CodeQL on every PR; gate at "no new critical/blocker" |
| SDLC-04 | Software composition analysis: Trivy + pip-audit on every PR |
| SDLC-05 | Container image scan: Trivy + Docker Scout, fail on HIGH/CRITICAL |
| SDLC-06 | DAST: OWASP ZAP baseline on every merge to main, full scan weekly |
| SDLC-07 | Manual API pentest at least once per release (OWASP API Top 10) |
| SDLC-08 | Pen-test report reviewed in retrospective; CVSS ≥7 fixes block release |

## 6. Operational Security Requirements

| ID | Requirement |
|----|-------------|
| OPS-01 | Falco rules cover MITRE ATT&CK enterprise techniques (T1059, T1611, T1610…) |
| OPS-02 | QRadar correlation rules raise an offense within 5 minutes of detection |
| OPS-03 | Runbooks for top 10 incident types (account takeover, data exfil, ransomware…) |
| OPS-04 | DR: RPO ≤15 min, RTO ≤1 hour; quarterly tabletop exercise |
| OPS-05 | Vulnerability management SLAs: Critical 24h, High 7d, Medium 30d |

## 6.5 CSRF — Documented as Not Applicable

| ID | Decision |
|----|----------|
| CSRF-01 | SecureBank's APIs are stateless and authenticated via the `Authorization: Bearer` header (JWT, RS256). No `Cookie`-based session is accepted by any state-changing endpoint. Browsers do not attach `Authorization` headers cross-origin without explicit JS, so CSRF is structurally not exploitable. |
| CSRF-02 | The optional refresh-token cookie (when used) is set with `Secure; HttpOnly; SameSite=Strict; Path=/v1/auth/token/refresh` — exercise scope is one endpoint that re-mints an access token; the response is JSON, never a redirect that an attacker can side-effect. |
| CSRF-03 | The API Gateway rejects any state-changing request whose `Origin` / `Referer` is not in the allow-list (configured per environment in `api-gateway/app/waf.py`). |
| CSRF-04 | Even so, all transfer requests carry a server-generated **idempotency key** in the body; replay of a captured request yields the original receipt rather than a duplicate debit (defense-in-depth). |

## 6.6 Formal Integrity / Confidentiality Models — BLP & Clark-Wilson

### Bell–LaPadula (Confidentiality)

We adopt a four-level lattice for read access:

| Level | Examples |
|-------|----------|
| `S` (Secret) | JWT signing keys, Vault root, TLS private keys |
| `C` (Confidential) | Argon2id hashes, refresh-token store, audit chain head |
| `R` (Restricted) | Customer PII, balances, transactions |
| `U` (Unclassified) | Public marketing pages, OpenAPI docs |

Rules enforced by OPA + RBAC:

* **Simple Security Property ("no read up")** — a subject (service account / role) labelled at level `L` may only `GET` resources whose label is `≤ L`. Encoded as REGO rule `bell_lapadula.allow_read`.
* **★-Property ("no write down")** — a subject at level `L` may only write to resources whose label is `≥ L`. Prevents an `R`-level service from exporting customer data into a `U`-level public endpoint.

OPA bundle `k8s/policies/opa/bell_lapadula.rego` (referenced in `04_framework_mapping.md`) enforces this on every API call via the per-service sidecar.

### Clark-Wilson (Integrity)

The transactional engine is structured around Clark-Wilson primitives:

| Clark-Wilson element | SecureBank realisation |
|----------------------|------------------------|
| **CDI** (Constrained Data Item) | Account balance row, transaction row, audit chain entry |
| **UDI** (Unconstrained Data Item) | Inbound HTTP request bodies *before* validation |
| **IVP** (Integrity Verification Procedure) | Database `CHECK (balance >= 0)` + hash-chain verifier job (cron) |
| **TP** (Transformation Procedure) | The single `transfer_funds()` stored procedure, run inside a `SERIALIZABLE` transaction; row-locks both accounts; appends a signed audit row |
| **Separation of Duty** | The user who initiates a transfer cannot also approve high-value ones — those route to an approver role (admin pair) |
| **Authentication** | Every TP is invoked only with a verified JWT whose `sub` is bound to the CDI's owner |
| **Triple (user, TP, CDI)** | The OPA owner-check policy materialises the `(sub, transfer_funds, account_id)` triple before allowing the call |

Audit consequence: every modification of a CDI is **append-only** in the audit chain; the chain head is hashed into the next entry, so any retroactive edit is detectable by the daily IVP run.

## 7. Privacy & Data Protection

| ID | Requirement |
|----|-------------|
| PRV-01 | Data minimization: collect only essential PII |
| PRV-02 | Right to erasure: customer-initiated PII deletion in ≤30 days |
| PRV-03 | Data residency: production data stays in-region (Pakistan) |
| PRV-04 | Consent ledger for marketing communications |

## 8. ASVS v5.0 Coverage Summary

| ASVS Chapter | Target Level | Status |
|--------------|--------------|--------|
| V1 Architecture | L2 | Met |
| V2 Authentication | L2 | Met |
| V3 Session | L2 | Met |
| V4 Access Control | L2 | Met |
| V5 Validation/Sanitization | L2 | Met |
| V6 Cryptography | L2 | Met (L3 deferred — needs HSM) |
| V7 Error Handling | L2 | Met |
| V8 Data Protection | L2 | Met |
| V9 Communications | L2 | Met |
| V10 Malicious Code | L1 | Met |
| V11 Business Logic | L2 | Met |
| V12 Files | L2 | N/A (no file upload in MVP) |
| V13 API | L2 | Met |
| V14 Config | L2 | Met |

## 9. Sign-off

| Role | Name | Date |
|------|------|------|
| Lead Developer | _________ | 2026-05-18 |
| Security Analyst | _________ | 2026-05-18 |
| DevSecOps Engineer | _________ | 2026-05-18 |
| Course Instructor | Engr. M. A. Nawaz | _________ |
