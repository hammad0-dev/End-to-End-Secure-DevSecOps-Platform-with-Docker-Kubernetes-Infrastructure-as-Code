# Live Demo Runbook — Red Team vs Blue Team

Use this script for the **June 12, 2026** exam defense.  Each step is
≤ 60 seconds; the full sequence fits comfortably in 15–18 minutes.

---

## 0. Pre-flight (done 30 min before)

| Check | Command |
|-------|---------|
| Cluster up | `kubectl get nodes -o wide` — 3 Ready |
| Services healthy | `kubectl get pods -A \| grep -v Running \| wc -l` → `0` |
| Vault unsealed | `kubectl exec -n securebank-sec vault-0 -- vault status \| grep Sealed` → `false` |
| Kafka up | `kubectl get kafkas -A` → `Ready` |
| Schema Registry up | `curl -k https://schema-registry.securebank-data:8081/subjects` returns `[]` or list |
| Grafana | `kubectl port-forward -n securebank-obs svc/grafana 3000:3000 &` |
| QRadar forwarder | `kubectl logs -n securebank-obs deploy/qradar-forwarder \| tail` |
| Demo data | `./docker/scripts/seed-demo-data.sh` |
| Browser tabs open | GUI · Grafana overview · Grafana security · Falco events · Kibana/Loki |

> **Roles during demo**: 1 narrator (presents slide), 1 GUI driver, 1 Red Team operator (terminal), 1 Blue Team operator (Grafana + Loki).

---

## 1. Introduction (1 min)

**Narrator** opens slide 1, names the team, explains the platform in one sentence:

> *"SecureBank is a banking platform we built from scratch in 20 days with security baked in at every layer — from the threat model down to the syscall sandbox."*

---

## 2. Golden Path (2 min)

**GUI driver**:

1. Open `https://app.securebank.local`
2. Sign in as `demo@securebank.local / Change-Me-On-First-Login!`
3. MFA prompt appears → enter TOTP from authenticator
4. Land on Dashboard → highlight KPIs, "Risk: Low", trust panel
5. **Open Account** → instantly visible in Accounts table
6. **Transfer** ₨ 250 to the test recipient → receipt rendered, notification pops

**Narrator** while this happens:

> *"Every action you just saw triggered an audit-log entry, an OPA policy decision, a JWT verification, and an HMAC-signed Kafka event. Nothing in this UI bypasses the gateway."*

---

## 3. Step-up MFA in action (1 min)

**GUI driver**:

1. Click **Transfer** → set amount **₨ 1,000,000**
2. Click Send → server returns `401 step-up MFA required`
3. Toast appears; transfer rejected

**Narrator**:

> *"That ₨10,000 threshold is configured server-side in OPA; the client cannot lie its way past it."*

---

## 4. Switch to Security Console (1 min)

**GUI driver** → top-right → **Security** (admin nav).

* Show live audit feed
* Show 4 KPIs (login failures, rate-limit hits, fraud alerts, Falco events)
* Show offense list + SOAR playbook buttons

---

## 5. Red Team #1 — Credential stuffing (1.5 min)

**Red Team operator** clicks the **"Credential stuffing"** button in the Security Console drill panel.

* Loop fires 12 wrong passwords against `victim@securebank.local`
* GUI audit feed scrolls with `auth.login.failed`
* Counter `secKpiFail` increments
* After 5 failures, account-lockout chip appears
* SOAR auto-runs **PB-001 block-IP** → confirm in Loki:

```bash
logcli query '{app="soar-service"} |= "PB-001"' --since=2m
```

**Blue Team** narrates the Grafana panel "Auth failures by IP" spiking and resetting.

---

## 6. Red Team #2 — JWT alg=none (1 min)

**Red Team** clicks **"JWT alg=none"**.

* `/v1/accounts/me` request crafted with `alg:"none"` JWT
* Server returns **401**
* Audit feed shows `jwt.verify.failed reason=alg_not_allowed`
* QRadar AQL `jwt-anomaly.aql` opens an offense — show in QRadar tab

---

## 7. Red Team #3 — SSRF to metadata (1 min)

**Red Team** clicks **"SSRF — link-local"**.

* Posts webhook URL `http://169.254.169.254/latest/meta-data/`
* `validate_webhook_url` rejects → `400 Webhook URL not allowed`
* Audit feed shows `ssrf.blocked`

---

## 8. Memory-safety drill (3 min) — *signature piece*

**Terminal**:

```bash
# Vulnerable image — should crash
docker run --rm securebank/vuln:demo bash attack.sh

# Hardened image — should refuse safely
docker run --rm securebank/hardened:demo bash attack.sh
```

**Lead Developer** narrates side-by-side `vuln.c` vs `hardened.c` source.

Then:

```bash
# Prove every mitigation is on:
docker run --rm --entrypoint=/verify_hardening.sh securebank/hardened:demo
```

**Blue Team**:

* `kubectl logs -n securebank-obs ds/falco | grep "Memory corruption"`
* Falco event present → QRadar AQL `memory-corruption.aql` opens offense
* SOAR auto-runs **PB-007 quarantine-pod** and **PB-004 cordon-node**

> Brief checkbox satisfied: *"Memory & Insecure Coding: Prevention of buffer overflows, format string, integer overflows"* — demonstrated **live**.

---

## 9. ML Fraud Detection (2 min)

**GUI driver** runs a series of **9 transfers** of ₨ 9,500 each within 60 seconds (mouse-trap pattern from the adversarial-ML scenario).

* Fraud detector flags transfer #6 → `fraud.alert` in audit feed
* Account auto-frozen by SOAR **PB-003**
* GUI shows account chip → `frozen`

**AI Security Agent**:

```bash
curl -s http://ai-security-agent.securebank-sec:8007/explain \
   -d '{"rule_id":"fraud-ml","context":{"src_account_id":"abc"}}' | jq
```

Output reads back the MITRE technique, severity, suggested playbook, and rationale — read aloud.

---

## 10. Compliance dashboards (1 min)

**Blue Team operator** switches tab to Grafana → **SecureBank Overview** dashboard:

* Service health (all green)
* JWT failures (spike from drill, now flat)
* Falco events (spike from drill, now flat)
* CIS pass rates (Docker 92%, K8s 96%)

---

## 11. Q&A talking points

| Question | Crisp answer |
|----------|--------------|
| How would you scale this to 1M users? | Horizontal scale via HPA + Kafka partitions; Postgres read replicas; Redis cluster mode. |
| What if Vault dies? | Raft 3-node; auto-unseal via Transit; restore drill in `docs/03_architecture.md` §10. |
| Why distroless? | No shell → blocks T1059; smaller attack surface; ~10× smaller images. |
| What about insider threats? | Audit log hash-chained; 4-eyes on admin TPs; Vault root tokens disabled. |
| Zero-day in a dependency? | Daily Trivy + pip-audit, image rebuild weekly, Cosign attestations. |
| Why both Kyverno and Gatekeeper? | Kyverno's YAML for mutate/generate; Gatekeeper's REGO for cluster-wide constraints. |

---

## 12. Worst-case recovery

If something breaks during the live demo:

1. `kubectl rollout undo deploy/<svc> -n securebank-app` (last known good)
2. Fall back to **docker-compose** locally — same code, same defenses
3. If a live step fails, show a short recorded backup segment if available (recommended file: `docs/presentation/backup-demo.mp4`).
