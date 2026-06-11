# Framework Mapping Matrix — SecureBank

How SecureBank's controls cross-reference every framework named in the project brief.

---

## 1. OWASP ASVS v5.0 ↔ Implementation

| ASVS ID | Control | Where Implemented |
|---------|---------|-------------------|
| V1.1.1 | Secure SDLC | `ci/.github/workflows/`, this repo's PR template |
| V1.4.1 | Trust boundaries documented | `docs/02_threat_model.md`, `docs/03_architecture.md` |
| V2.1.1 | No max password length cap | `src/shared/securebank_shared/auth.py` |
| V2.1.5 | Breached password check | `src/auth-service/app/hibp.py` |
| V2.4.1 | Argon2id default | `src/shared/securebank_shared/auth.py` |
| V2.7.x | MFA via TOTP | `src/auth-service/app/mfa.py` |
| V2.8.x | Step-up auth | `src/transaction-service/app/risk.py` |
| V3.2.x | Session token strength | `src/shared/securebank_shared/sessions.py` |
| V3.3.x | Session timeouts | Redis TTL 15 min idle |
| V4.1.x | Least privilege | OPA REGO bundles `k8s/policies/opa/` |
| V4.2.x | Insecure direct object refs | UUIDv7 IDs; OPA owner-check policy |
| V5.1.x | Validation | Pydantic v2 strict models |
| V5.2.x | Sanitization | `bleach` for any HTML render path |
| V5.3.x | Output encoding | `Content-Security-Policy: default-src 'self'` |
| V6.2.x | Approved algorithms | AES-256-GCM, RS256, Argon2id |
| V6.3.x | RNG | `secrets` module / `os.urandom` |
| V6.4.x | Key management | Vault Transit |
| V7.x | Error handling | Structured JSON logger w/ redaction; generic 5xx to clients |
| V8.1.x | Data protection | Column-level encryption + tokenization |
| V8.3.x | Sensitive private data | Vault-only storage of secrets |
| V9.1.x | TLS 1.3 only | Envoy + uvicorn config |
| V9.2.x | Cert pinning | mTLS via Vault PKI |
| V11.x | Business logic | Idempotency keys, atomic balance updates |
| V13.1.x | API generic | OpenAPI spec + ZAP scan |
| V13.2.x | REST | Method allow-list; deny `OPTIONS` reflection |
| V13.3.x | GraphQL | Not used (out of scope) |
| V14.1.x | Configuration | Immutable infra, no secrets in env-file |
| V14.2.x | Dependency | pip-audit + Trivy daily |

## 2. NIST CSF v2.0

| Function | Category | SecureBank Implementation |
|----------|----------|---------------------------|
| **GOVERN** | GV.OC – Org Context | Project charter, role assignments |
| | GV.RM – Risk Management | DREAD scoring, risk register in `docs/02_threat_model.md` |
| | GV.SC – Supply Chain | SBOM, Cosign, dependency policy |
| **IDENTIFY** | ID.AM – Asset Management | Asset table in `docs/02_threat_model.md` §1.3 |
| | ID.RA – Risk Assessment | Threat model + pentest |
| | ID.IM – Improvement | Quarterly review cadence |
| **PROTECT** | PR.AA – Identity, Authn, Access | OAuth2/OIDC + MFA + RBAC/OPA |
| | PR.DS – Data Security | Encryption at rest + in transit + tokenization |
| | PR.PS – Platform Security | CIS K8s + CIS Docker, Pod Security Standards |
| | PR.IR – Tech Infra Resilience | HA replicas, PDB, multi-AZ |
| **DETECT** | DE.CM – Continuous Monitoring | Prometheus + Loki + Falco |
| | DE.AE – Anomalies & Events | ML detector + QRadar correlation |
| **RESPOND** | RS.MA – Incident Management | Runbooks in `docs/06_red_blue_team.md` |
| | RS.AN – Analysis | QRadar offenses, Loki forensics |
| | RS.MI – Mitigation | Automated playbook to isolate pod (kubectl cordon) |
| **RECOVER** | RC.RP – Recovery Plan | Velero + WAL-G + DR runbook |
| | RC.IM – Improvements | Post-incident review template |

## 3. NIST SP 800-53 Rev.5 (Selected)

| Control Family | Control | How Met |
|---------------|---------|---------|
| AC – Access Control | AC-2, AC-3, AC-6 | OAuth + RBAC + OPA least-privilege |
| AU – Audit | AU-2, AU-3, AU-9 | JSON audit logs, hash-chained, Loki retention |
| CM – Config Mgmt | CM-2, CM-7 | Terraform + GitOps; deny unused ports |
| CP – Contingency | CP-9, CP-10 | Velero backup + tested restore |
| IA – Identification | IA-2, IA-5 | Argon2id, MFA, breached-password |
| IR – Incident Response | IR-4, IR-6 | Runbooks + QRadar + SOC channel |
| RA – Risk | RA-3, RA-5 | Threat model + Trivy + SAST |
| SA – System Acquisition | SA-15 | Secure SDLC documented |
| SC – System & Comms | SC-7, SC-8, SC-12, SC-13, SC-28 | NetworkPolicies, TLS 1.3, Vault, AES-256 |
| SI – System & Info Integrity | SI-3, SI-4, SI-7 | Falco, Cosign, image verification |

## 4. NIST SP 800-207 (Zero Trust)

See `docs/03_architecture.md` §2.

## 5. ISO/IEC 27001:2022 Annex A (Selected)

| Annex A Control | SecureBank Element |
|-----------------|--------------------|
| A.5.7 Threat intelligence | MITRE ATT&CK feed → QRadar |
| A.5.15 Access control | RBAC + OPA |
| A.5.23 Information security for use of cloud services | This document + CSP shared-responsibility note |
| A.8.2 Privileged access rights | Vault root tokens disabled, only AppRoles |
| A.8.5 Secure authentication | OAuth2 + MFA |
| A.8.7 Protection against malware | Trivy + Falco + image signature |
| A.8.9 Configuration management | Terraform + GitOps |
| A.8.16 Monitoring activities | Prometheus/Loki/Falco/QRadar |
| A.8.23 Web filtering | Egress NetworkPolicy + DNS allow-list |
| A.8.24 Use of cryptography | TLS 1.3 + AES-256-GCM + Argon2id + Vault Transit |
| A.8.25 Secure development lifecycle | `ci/` pipelines + this doc |
| A.8.26 Application security requirements | `docs/01_SRD.md` |
| A.8.28 Secure coding | bandit, ruff, SonarQube, CodeQL |

## 6. ISO/IEC 27034 — Application Security Controls

ISO 27034 expects the org to maintain an Application Security Control (ASC) library; we adopt OWASP ASVS as the ASC library and reference each control by ASVS ID in code comments (see `# ASVS V2.4.1` style).

| 27034 Element | Where |
|---------------|-------|
| ONF (Org Normative Framework) | This document |
| ANF (App Normative Framework) | `docs/01_SRD.md` + ASVS table above |
| Application Security Life Cycle (ASLC) | Maps to phases 1-7 in project brief |

## 7. CSA Cloud Controls Matrix (CCM) v4

| Domain | Control | Implementation |
|--------|---------|----------------|
| AIS – App & Interface Security | AIS-03 | API Gateway + JWT + OPA |
| AIS-07 | Vulnerability scanning | Trivy + ZAP |
| CCC – Change Control | CCC-04 | GitOps PR review + branch protection |
| DCS – Data Center Security | DCS-09 | K8s topology spread + multi-AZ sim |
| DSP – Data Security & Privacy | DSP-10 | Field-level encryption + tokenization |
| GRC – Governance & Risk | GRC-04 | This framework matrix; risk register |
| IAM – Identity & Access | IAM-08/09/14 | OAuth2/OIDC + MFA + Vault dynamic creds |
| IPY – Interoperability | IPY-01 | Standard OAuth/OIDC + Kafka protocols |
| IVS – Infra & Virt Security | IVS-04 | NetworkPolicies + service mesh mTLS |
| LOG – Logging & Monitoring | LOG-04/08/13 | Loki + QRadar + Falco |
| SEF – Sec Incident Mgmt | SEF-03/04 | Runbooks + DR drill |
| TVM – Threat & Vuln Mgmt | TVM-02/03 | SAST + DAST + SCA in CI |
| UEM – Universal Endpoint Mgmt | n/a | Customer endpoints out of scope |

## 8. SABSA Matrix Summary

See `docs/03_architecture.md` §1.

## 9. MITRE ATT&CK Coverage

See `docs/02_threat_model.md` §5 — every documented threat references its ATT&CK technique. Falco rules and QRadar correlation rules in `monitor/falco/rules/securebank.yaml` and `monitor/qradar/rules/` are tagged with technique IDs.

## 10. CIS Benchmarks

### Docker (CIS Docker 1.6.0)

| Control | Status | Evidence |
|---------|--------|----------|
| 1.1 Host: separate partition for /var/lib/docker | N/A in K8s | — |
| 2.x Daemon | Pass | `docker info` snapshot in `reports/cis-docker/` |
| 4.1 Create user for container | Pass | `USER 10001` in every Dockerfile |
| 4.5 Cosign images | Pass | CI signs with Cosign |
| 4.6 Healthcheck instructions | Pass | `HEALTHCHECK` in every Dockerfile |
| 4.9 COPY over ADD | Pass | All Dockerfiles use COPY |
| 5.x Runtime | Enforced by K8s SecurityContext — see compliance report |

### Kubernetes (CIS K8s 1.9.0)

| Section | Status | Evidence |
|---------|--------|----------|
| 1 Control plane | Pass | kube-bench output in `reports/cis-k8s/` |
| 2 etcd | Pass | TLS + peer auth, encryption at rest with KMS |
| 3 Worker | Pass | kubelet readOnlyPort 0; anonymous-auth false |
| 4 Policies | Pass | RBAC, NetworkPolicy default-deny, Pod Security Standards `restricted` |
| 5 Pod Security | Pass | All workloads `runAsNonRoot`, `readOnlyRootFilesystem`, drop ALL caps |

## 11. STRIDE / PASTA / DREAD

See `docs/02_threat_model.md`.

## 11.5 Bell-LaPadula & Clark-Wilson (Formal Models)

The brief lists **BLP** and **Clark-Wilson** under "Security Frameworks &
Compliance".  SecureBank implements both:

| Model | Where enforced | Code |
|-------|---------------|------|
| Bell-LaPadula (confidentiality) | OPA sidecar at every API call | [`k8s/policies/opa/bell_lapadula.rego`](../k8s/policies/opa/bell_lapadula.rego) |
| Clark-Wilson (integrity, SoD, IVP) | OPA + DB stored procedures + append-only audit chain | [`k8s/policies/opa/clark_wilson.rego`](../k8s/policies/opa/clark_wilson.rego) |

See [`docs/01_SRD.md`](01_SRD.md#66-formal-integrity--confidentiality-models--blp--clark-wilson) for the lattice, CDI/UDI/TP/IVP mapping, and separation-of-duty rules.

## 11.6 Kafka Schema Registry

Avro schemas in [`src/shared/schemas/`](../src/shared/schemas/) are registered with the
Confluent Schema Registry deployed by [`k8s/kafka/schema-registry.yaml`](../k8s/kafka/schema-registry.yaml)
with compatibility level `FULL_TRANSITIVE`.  Both producer (`transaction-service`) and
consumers (`fraud-detection-service`, `notification-service`) validate every message
against the registered schema before serialising / processing.  This realises the brief's
"Schema Registry" requirement under Event-Driven Architecture.

## 12. OWASP API Security Top 10 (2023)

| API# | Risk | Mitigation |
|------|------|-----------|
| API1 | Broken Object Level Authz | OPA owner-check policy on every object access |
| API2 | Broken Authentication | OAuth2/OIDC + JWT + MFA + breached-pw |
| API3 | Broken Object Property Level Authz | Pydantic response models strip sensitive fields |
| API4 | Unrestricted Resource Consumption | Rate limit + body size limit + payload schema |
| API5 | Broken Function Level Authz | RBAC verified server-side; admin path separated |
| API6 | Unrestricted Access to Sensitive Business Flows | Per-flow rate limit + risk scoring |
| API7 | SSRF | URL allow-list + DNS resolver pinning |
| API8 | Security Misconfiguration | Trivy config scan + OPA Gatekeeper |
| API9 | Improper Inventory Management | OpenAPI spec versioned; deprecated routes return 410 |
| API10 | Unsafe Consumption of APIs | Outbound TLS verify + circuit breaker |
