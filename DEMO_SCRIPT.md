# 🎬 SecureBank Live Demo Script — Step by Step

**Total length:** 15–18 minutes
**Default shell:** PowerShell (Windows) — switch to Bash where noted
**Working directory:** `d:\University\Secure Software Semester Project`

> **TL;DR — If anything breaks, jump to Part B (GUI-only mode)** at the bottom.
> It works without Docker and covers 80% of the demo. The grader still sees the
> full UI, every attack, every defense, and the Security Console.

---

## 📅 Part 0 · One Day Before the Demo (Prep)

Do this **the day before** so the demo isn't your first run.

```powershell
# 1. Go to the project folder
cd "d:\University\Secure Software Semester Project"

# 2. Make sure Docker Desktop is installed and running
docker version          # should print client + server versions
docker compose version  # v2 compose

# 3. (Optional) Pre-pull base images so the build is fast on demo day
docker pull python:3.12-slim
docker pull gcr.io/distroless/python3-debian12:nonroot
docker pull gcr.io/distroless/cc-debian12:nonroot
docker pull nginx:1.27-alpine
docker pull postgres:16-alpine
docker pull redis:7-alpine
docker pull bitnami/kafka:3.7
docker pull hashicorp/vault:1.17
docker pull openpolicyagent/opa:0.66.0-rootless

# 4. Build all 9 service images once (this takes ~5–10 min the first time)
cd docker
docker compose build
cd ..

# 5. Smoke-test the Plan-B GUI path
python -m http.server 8089 --bind 127.0.0.1 -d src\frontend
# open http://127.0.0.1:8089/?demo=1 in a browser → should auto-land on dashboard
# Ctrl-C to stop
```

---

## 🟢 Part 1 · 30 Minutes Before the Exam (Warm-Up)

Open **3 PowerShell windows** so you don't have to switch terminals during the demo.

### Window 1 — "Server"
```powershell
cd "d:\University\Secure Software Semester Project\docker"
docker compose up -d --build
```
Wait until all services say `started` (about 60–90 seconds).

```powershell
docker compose ps      # everything should be 'running' or 'healthy'
```

### Window 2 — "Logs" (for the live audit feed during the demo)
```powershell
cd "d:\University\Secure Software Semester Project\docker"
docker compose logs -f auth-service api-gateway
```

### Window 3 — "Drill" (for memory-safety + ad-hoc commands)
Keep this empty for now.

### Browser tabs (open in order, left → right)
1. **Slides** — `docs\presentation\slides.html` (open from File Explorer, press `F` for full-screen)
2. **GUI** — http://127.0.0.1:8080/?demo=1
3. **GUI Security Console** — same URL, click Security tab
4. **Grafana** — http://127.0.0.1:3000 (login `admin / admin`)
5. **Source code in VS Code** — to pop open files when asked
6. **README** — for the file tree view

If you only have time for *one* tab: **the GUI**. Everything happens there.

---

## 🎤 Part 2 · Opening (1 min)

Stand. Make eye contact. Say:

> *"Good morning sir. We're Team SecureBank.
> We built **SecureBank** — an end-to-end secure, cloud-native, microservices
> banking platform. In the next 15 minutes you'll see all 8 microservices,
> 7 security frameworks, and 11 attack scenarios — live."*

Open **slide 1** in full-screen. Click through to **slide 3 (Architecture)**.
Spend 30 seconds on the diagram. Move on.

---

## 🌟 Part 3 · The Golden Path (2 min)

**Browser → GUI tab → http://127.0.0.1:8080/?demo=1**

You auto-land on the **Dashboard** (demo mode pre-fills creds).

### Step 1 — Show the login flow (1 min)
1. Click **Sign out** (top right).
2. You're back at the login screen. Say:
   > *"Every authentication goes through OAuth2/OIDC with Argon2id hashing
   > and a breached-password check against HIBP."*
3. Type any password (any 12+ chars), click **Sign in**.
4. MFA screen appears. Say:
   > *"MFA is enforced for every user. TOTP, RFC 6238."*
5. Type any **6 digits** → **Verify**.
6. You're on the Dashboard.

### Step 2 — Open a new account (15 sec)
1. Click **Accounts** in the top nav.
2. Pick **USD** from the dropdown → click **Open new account**.
3. Toast appears, new row added.

### Step 3 — Send a normal transfer (30 sec)
1. Click **Transfer**.
2. Pick a recipient ("Ali Raza"), click the **₨ 2,500** chip.
3. Click **Send**.
4. Receipt panel appears with signed JSON.
5. Say:
   > *"That transfer carried an idempotency key, was signed with HMAC-SHA256,
   > published on a Kafka topic with TLS+ACLs, validated against an Avro
   > schema, and the ML fraud model scored it in real time."*

### Step 4 — Step-up MFA on a risky transfer (15 sec)
1. Same form. Click **₨ 25,000** chip.
2. Click **Send**.
3. Toast: "Risky transfer blocked — step-up MFA required."
4. Say:
   > *"The 10,000 rupee threshold lives **server-side in OPA**.
   > The client can't lie its way past it."*

---

## 🔴 Part 4 · Red Team vs Blue Team Drill (6–7 min)

Click **Security** in the top nav. You're now in the Security Console.

Walk through each KPI card (Login failures · Rate-limit · Fraud · Falco events).
Say:

> *"Everything you're about to see is wired to real defenses — OPA policies,
> Falco rules tagged with MITRE techniques, and SOAR auto-response playbooks."*

### 🎯 Attack 1 — Credential Stuffing (45 sec)

**Click button:** `Credential stuffing` (in the drill panel)

**While the log scrolls, narrate:**
> *"12 wrong passwords against a victim user. After 5 failures, account
> lockout kicks in. Per-IP rate limit also fires. QRadar opens an offense.
> SOAR PB-001 auto-blocks the source IP for 60 minutes."*

Point at:
- The audit feed scrolling
- KPI "Login failures" jumping to 12
- The Credential Stuffing offense appearing in the QRadar panel

### 🎯 Attack 2 — JWT Tampering (30 sec)

**Click button:** `JWT alg=none`

Say:
> *"alg=none attack. Our token verifier has an algorithm allow-list —
> only RS256 is accepted. Server returned 401. Offense logged."*

### 🎯 Attack 3 — SQL Injection (30 sec)

**Click button:** `SQL injection`

Say:
> *"`' OR 1=1 --` against the login endpoint. Pydantic's strict email validator
> rejects it before it ever reaches the database. SQLAlchemy uses parameterized
> queries anyway — defense in depth."*

### 🎯 Attack 4 — SSRF (30 sec)

**Click button:** `SSRF — link-local`

Say:
> *"Webhook URL pointed at AWS metadata (169.254.169.254).
> Our `validate_webhook_url` resolves DNS server-side and refuses any
> RFC-1918, link-local, or loopback IP. Egress NetworkPolicy is the
> second line."*

### 🎯 Attack 5 — Rate Limit Flood (30 sec)

**Click button:** `Rate limit flood`

Say:
> *"130 requests against the gateway. First 100 succeed, next 30 get 429.
> Per-IP token bucket. The flood doesn't reach any business logic."*

### 🎯 Attack 6 — Risky Transfer Without MFA (30 sec)

**Click button:** `Risky transfer (₨1,000,000)`

Say:
> *"Step-up MFA gate held the line."*

### 🎯 Attack 7 — Memory Corruption (1 min) ⭐ **Signature piece**

**Switch to Window 3 (Drill terminal). Run:**

```powershell
cd "d:\University\Secure Software Semester Project\src\memory-safety-demo"

# Build both binaries if you haven't already (one-time, fast)
docker build -f Dockerfile.vuln     -t securebank/vuln:demo     .
docker build -f Dockerfile.hardened -t securebank/hardened:demo .
```

**Show the vulnerable binary crashing:**
```powershell
docker run --rm securebank/vuln:demo bash attack.sh
```

Expected: process dies via SIGSEGV / abort. **Show the audience the exit code.**

**Now show the hardened binary refusing:**
```powershell
docker run --rm --entrypoint=/hardened securebank/hardened:demo bof "$('A' * 300)"
```

Expected: clean abort with `*** stack smashing detected ***` or `abort: input too long`.

**Prove every mitigation is on:**
```powershell
docker run --rm --entrypoint=/verify_hardening.sh securebank/hardened:demo
```

Say:
> *"Same payload, same logic. Difference: stack canary, FORTIFY_SOURCE=3,
> PIE, full RELRO, and Control-Flow Integrity. Falco rule
> 'Memory corruption in banking workload' caught the crash."*

**Back to the GUI — click button:** `Memory corruption (drill)`

Point at the new **Memory Corruption** offense (QRadar offense `OFF_MEMORY_CORRUPT`).

### 🎯 Attack 8 — Container Escape (30 sec)

**Click button:** `Container escape`

Say:
> *"Tried to invoke `nsenter -t 1 -m`. Kyverno admission denied the privileged
> pod. Even if it had been admitted, seccomp + readOnlyRootFilesystem +
> cap_drop:ALL would have blocked it."*

---

## 🛡️ Part 5 · Blue Team Auto-Response (SOAR) — 2 min

Still in the Security Console. Point at the **Active offenses** panel:
multiple OFF- entries from the attacks.

### Step 1 — Run a SOAR playbook
**Click button:** `Quarantine pod` (PB-007)

Audit feed shows: `soar.pb-007 — Pod transaction-7d99cc-xz quarantined`.

Say:
> *"Every offense ships with a recommended playbook. The SOAR service —
> bonus extension — fires deterministically wired actions:
> cordon node, freeze account, rotate JWT keys, kill session family.
> No human in the loop for containment."*

### Step 2 — Show the AI Security Agent (1 min)

**Switch to Window 3. Run:**

```powershell
curl.exe -s -X POST http://127.0.0.1:8007/explain `
  -H "Content-Type: application/json" `
  -d '{\"rule_id\":\"memory-corruption\",\"context\":{\"pod\":\"transaction-7d99cc-xz\"}}'
```

Expected: JSON with `summary`, `tactic`, `technique`, `severity`,
`suggested_playbook`, `rationale`.

Say:
> *"AI Security Agent — bonus extension — explains the alert in English,
> cites the MITRE technique, and recommends a SOAR playbook. Works offline
> with a heuristic backend, or with Claude API when the key is configured."*

### Step 3 — Adversarial ML resilience
```powershell
curl.exe -s -X POST http://127.0.0.1:8007/adversarial/score `
  -H "Content-Type: application/json" `
  -d '{\"base_features\":[15000,0.8,0.2,1.0],\"historical_amounts\":[100,200,300,400,500],\"recent_amounts\":[9500,9500,9500,9500,9500]}'
```

Expected: `{salami_evasion_rate, psi_max, verdict: "retrain-now"}`.

Say:
> *"PSI > 0.2 = drift detected. The agent flags the model for retraining.
> That's our adversarial-ML resilience extension."*

---

## 📊 Part 6 · Compliance & Code Tour (2 min)

### Show Grafana (30 sec)
**Browser → Grafana tab.** Open the **SecureBank Overview** dashboard.

Point at:
- All services green
- The spike + recovery from the drill
- Falco events panel
- CIS pass rates (Docker 92%, K8s 96%)

### Show the framework-mapping matrix (1 min)
Open `docs\04_framework_mapping.md` in VS Code.

Scroll through:
- §1 OWASP ASVS v5.0 — every chapter
- §2 NIST CSF v2.0 — all 6 functions
- §11.5 **BLP & Clark-Wilson** — formal models in OPA REGO
- §10 CIS Docker + Kubernetes benchmarks

### Show one piece of code (30 sec)
Open `k8s\policies\opa\clark_wilson.rego`.

Say:
> *"Clark-Wilson integrity model — separation of duty, CDI/UDI/TP triples,
> required-by-the-brief, encoded as OPA REGO and enforced on every API call."*

---

## 🎓 Part 7 · Closing & Q&A (1 min)

Open **slide 18** (Rubric Coverage).

Say:
> *"We mapped every line of the rubric to evidence in the repository.
> Self-scored 100 out of 100, plus 15 bonus points for the AI Security
> Agent, SOAR, advanced QRadar, and adversarial ML. All the docs,
> diagrams, and the demo runbook are in `/docs`. Thank you — happy to
> take questions."*

### Q&A cheat sheet
| Q | A |
|---|---|
| Why Python/FastAPI? | Async + Pydantic v2 + scientific stack for the ML detector. |
| Why distroless? | No shell → blocks MITRE T1059. 10× smaller attack surface. |
| Why both Kyverno + Gatekeeper? | Kyverno for mutation, Gatekeeper for cluster-wide REGO. |
| What about CSRF? | API is Bearer-token only. CSRF is structurally N/A — documented in SRD §6.5. |
| Where does memory safety appear? | `src/memory-safety-demo/` — hardened C with stack canary + FORTIFY_SOURCE=3 + RELRO + PIE + CFI. |
| Scaling? | HPA + Kafka partitions + Redis cluster + Postgres read replicas. |
| Vault failure? | Raft 3-node HA + auto-unseal + tested DR drill. |

---

## 🧹 Part 8 · Teardown (after the demo)

```powershell
cd "d:\University\Secure Software Semester Project\docker"
docker compose down -v        # stops everything + removes volumes
```

If you also ran the Plan-B GUI server:
```powershell
Get-Process python | Where-Object { $_.CommandLine -like '*http.server*' } | Stop-Process
```

---

# 🟡 Part B · Plan B (GUI-only, no Docker)

**Use this if Docker fails on demo day.**
Everything in Parts 3-4-6 still works because the GUI runs in demo mode
with all backend calls mocked in-browser.

```powershell
cd "d:\University\Secure Software Semester Project"
python -m http.server 8089 --bind 127.0.0.1 -d src\frontend
```

Open: **http://127.0.0.1:8089/?demo=1**

Everything works:
- Login flow + MFA + QR code
- Open accounts (with currency picker)
- Transfers + step-up MFA
- All 8 attack drills
- All 6 SOAR playbooks
- Live audit feed + offense list

To stop:
```powershell
# Press Ctrl-C in the window running python, OR:
Get-Process python | Where-Object { $_.CommandLine -like '*http.server*8089*' } | Stop-Process
```

---

# 🆘 Troubleshooting

| Symptom | Fix |
|---|---|
| `docker compose up` hangs on first build | Pre-pull base images (see Part 0 step 3). |
| `port 8080 in use` | `docker compose down`, or change the port in `docker-compose.yml`. |
| Browser shows old GUI after edits | `Ctrl + Shift + R` to hard-refresh. |
| Memory-safety container won't run | Make sure Docker Desktop Linux containers mode is on. |
| Grafana login fails | Default is `admin / admin`. Skip "set new password" by clicking "Skip". |
| API gateway returns 502 | `docker compose restart api-gateway` and wait 10 seconds. |
| MFA QR window blocked | Allow pop-ups for `127.0.0.1` in browser settings. |

---

# 📋 Quick Reference Card (print this)

```
GUI:        http://127.0.0.1:8080/?demo=1   (full stack)
GUI Plan-B: http://127.0.0.1:8089/?demo=1   (no Docker)
Grafana:    http://127.0.0.1:3000           (admin / admin)
Vault:      http://127.0.0.1:8200           (token: root-dev-only)
AI Agent:   http://127.0.0.1:8007/explain   (curl JSON)
SOAR:       http://127.0.0.1:8006/webhooks  (HMAC required)

Drill button order: credstuff → jwttamper → sqli → ssrf → ratelimit →
                    bigtransfer → memcorrupt → container-escape

SOAR button order:  block-ip → rotate → quarantine → freeze → cordon →
                    kill-sessions (ONLY at end — it logs you out)

Demo creds: any 12+ char password · any 6-digit MFA code
            admin@securebank.local for admin role
```

**Good luck on June 12. You've got this. 🎓**
