# 🏁 SecureBank — Platform Execution & Video Recording Guide

This runbook provides complete, command-by-command instructions for starting the SecureBank platform on Windows. It also includes a detailed **Video Recording Timeline & Script** to help you record a polished 15-minute presentation for your CYC386 final exam, along with a complete directory of all usernames, passwords, tokens, and port mappings.

---

## 🔑 Credentials, Ports, & Endpoints Directory

This registry contains every username, password, token, port, and URL configured across the local environment.

| Component / Service | Local URL / Endpoint | Default Username / Email | Default Password / Secret / Token | Notes |
| :--- | :--- | :--- | :--- | :--- |
| **Frontend Web App (Full Stack)** | `http://localhost:8080` | `demo@securebank.local` <br> `admin@securebank.local` | `Change-Me-On-First-Login!` <br> *Any 12+ character password* | Hardened Nginx serving the SPA. Demands MFA. Password rotation forced on first boot. |
| **Frontend Web App (Plan B)** | `http://127.0.0.1:8089/?demo=1` | `demo@securebank.local` <br> `admin@securebank.local` | `Change-Me-On-First-Login!` <br> *Any 12+ character password* | Lightweight Python local server using browser-side mock fixtures. |
| **API Gateway** | `http://localhost:8443` | N/A | N/A | Uvicorn/FastAPI reverse proxy with rate limiting, input validation, and WAF rules. |
| **Grafana Monitoring** | `http://localhost:3000` | `admin` | `securebank-dev-only` | Pre-configured metrics/logs console (Loki + Prometheus + Falco events). |
| **HashiCorp Vault** | `http://localhost:8200` | N/A | Root Token: `root-dev-only` | Manages transit encryption, PKI CA certificates, and dynamic DB credentials. |
| **Open Policy Agent (OPA)** | `http://localhost:8181` | N/A | N/A | Evaluates Rego security models (Clark-Wilson, Bell-LaPadula authorization). |
| **AI Security Agent** | `http://localhost:8007` | N/A | N/A | Provides `/explain` and `/adversarial/score` endpoints (runs offline by default). |
| **SOAR Service** | `http://localhost:8006` | Callback HMAC Secret | `securebank-dev-webhook-secret-change-me` | Receives alerts and executes automated playbooks (e.g. block-IP, quarantine). |
| **PostgreSQL Database** | `localhost:5432` | `securebank` | `securebank-dev-only-change-me` | Main relational database storage. |
| **Redis Cache** | `localhost:6379` | N/A | `securebank-dev-only` | Caches sessions, gateway rate-limiter buckets, and SOAR states. |
| **Apache Kafka** | `localhost:9092` | N/A | N/A | Message broker handling transfers, secured via mTLS and ACLs. |
| **Prometheus** | `http://localhost:9090` | N/A | N/A | Metrics scraper. |
| **Loki Aggregator** | `http://localhost:3100` | N/A | N/A | Aggregates microservice stdout logs for Grafana and SOAR. |

---

## 🚀 Command-by-Command Run Guide (Windows)

Choose either **Method A** (Docker Compose - Full DevSecOps Stack) or **Method B** (Lightweight Mock Mode - No Docker) depending on your machine's resources and Docker health.

### Method A: Full Stack via Docker Compose
This method spins up all microservices, databases, brokers, and the monitoring stack.

#### Step 1: Open Git Bash
Because the setup scripts (`.sh` files) contain Unix logic, execute these commands inside **Git Bash** (installed by default with Git for Windows). Do NOT use command prompt.
```bash
# Go to the project root directory
cd "c:/Users/sheik/Downloads/Secure Software Semester Project/Secure Software Semester Project"
```

#### Step 2: Generate Service Certificates (mTLS)
Run the SSL/TLS generation script to create certificates for internal mTLS communication between the gateway, auth, and business services.
```bash
# Move to the docker directory
cd docker

# Run the cert generator
./scripts/gen-certs.sh
```
*Verification:* You should see `Certs written to ./certs`. Verify that files like `ca.crt`, `api-gateway.crt`, and `auth-service.crt` exist inside `docker/certs/`.

#### Step 3: Pre-pull Base Docker Images (Recommended)
Docker builds can take time during live evaluations. Pre-pulling the heavy official base images saves time:
```bash
docker pull python:3.12-slim
docker pull gcr.io/distroless/python3-debian12:nonroot
docker pull gcr.io/distroless/cc-debian12:nonroot
docker pull nginx:1.27-alpine
docker pull postgres:16-alpine
docker pull redis:7-alpine
docker pull confluentinc/cp-zookeeper:7.5.0
docker pull confluentinc/cp-kafka:7.5.0
docker pull hashicorp/vault:1.17
docker pull openpolicyagent/opa:0.66.0
docker pull prom/prometheus:v2.55.0
docker pull grafana/grafana:11.2.0
docker pull grafana/loki:3.1.1
docker pull grafana/promtail:3.1.1
```

#### Step 4: Build & Start the Container Stack
Start the core services and the security/monitoring overlay containers:
```bash
docker compose -f docker-compose.yml -f docker-compose.security.yml up -d --build
```
*Note:* Give the services about 60–90 seconds to fully spin up. Check the status using:
```bash
docker compose ps
```
All containers should report `running` or `healthy`.

#### Step 5: Bootstrap HashiCorp Vault (Critical)
Once the `vault` container is running, initialize its transit encryption, PKI role boundaries, and policies:
```bash
./scripts/init-vault.sh
```
*Verification:* Script should print `Vault bootstrap complete.`

#### Step 6: Verify Network Connectivity
Verify that the frontend and gateway are active:
- Open your browser to `http://localhost:8080` to access the SecureBank GUI.
- Test the gateway health check endpoint in a separate PowerShell window:
  ```powershell
  Invoke-RestMethod -Uri http://localhost:8443/health
  ```
  Expected output: `{"status":"healthy","service":"api-gateway",...}`

#### Step 7: Access the Monitoring Stack
- Open Grafana: `http://localhost:3000`
- Log in with credentials: Username: `admin` / Password: `securebank-dev-only` (skip changing the password when prompted).
- Select the **SecureBank Overview** dashboard to watch real-time metrics.

---

### Method B: Plan B (Standalone Mock GUI Mode)
Use this if Docker Desktop experiences issues, crashes, or runs slowly on your machine. This runs the frontend code using a basic Python web server and mocks the backend inside the browser. It implements 80% of the rubrics without requiring Docker, databases, or external ports.

#### Step 1: Open PowerShell
Open standard Windows PowerShell:
```powershell
cd "c:\Users\sheik\Downloads\Secure Software Semester Project\Secure Software Semester Project"
```

#### Step 2: Launch Python HTTP Server
Run Python's built-in server directed at the frontend code folder:
```powershell
python -m http.server 8089 --bind 127.0.0.1 -d src/frontend
```

#### Step 3: Open Browser
Navigate to the special demo URL:
- **`http://127.0.0.1:8089/?demo=1`**
Adding the `?demo=1` query parameter overrides fetch requests and redirects authentication and transactions to the browser’s internal JavaScript mock fixture engine. Everything (MFA, transfers, attacks, playbooks, security dashboards) will run cleanly in-browser!

---

### 🛡️ Memory Safety Hardening Demo (C Binaries)
The signature piece of the security implementation compares a vulnerable C binary with one built using compiler mitigations (canaries, ASLR, read-only structures).

Run these commands in a separate PowerShell window:
```powershell
# Go to the memory safety directory
cd "c:\Users\sheik\Downloads\Secure Software Semester Project\Secure Software Semester Project\src\memory-safety-demo"

# 1. Build the vulnerable and hardened containers
docker build -f Dockerfile.vuln     -t securebank/vuln:demo     .
docker build -f Dockerfile.hardened -t securebank/hardened:demo .

# 2. Run the vulnerable container to demonstrate a crash (Buffer Overflow)
docker run --rm securebank/vuln:demo bash attack.sh
# Expected: The attack completes, causing a "Segmentation Fault (SIGSEGV)" or exit 139.

# 3. Run the hardened container with the same payload
docker run --rm --entrypoint=/hardened securebank/hardened:demo bof "$('A' * 300)"
# Expected: Clean termination with "*** stack smashing detected ***" or "abort".

# 4. Run the validation script to prove compiler mitigations are active
docker run --rm --entrypoint=/verify_hardening.sh securebank/hardened:demo
# Expected output will show:
# - Stack Canary: YES
# - NX (No-Execute) Bit: YES
# - PIE (Position Independent Executable): YES
# - RELRO: FULL
```

---

## 📹 Video Recording Script & Timeline (15 Minutes)

Use this minute-by-minute guide to record your presentation video.

### ⏱️ 0:00 - 1:30 | Introduction & Architecture
* **On-Screen Visuals:** Slide 1 (Title slide) followed by Slide 3 (Architecture / Threat Model C4 Diagram) from `docs/presentation/slides.html` or Marp export.
* **Presenter Actions:** State your names, group details, and the project scope. Zoom into the architecture diagram to discuss threat boundaries.
* **Talking Points:**
  > *"Good morning. We are Team SecureBank. We developed SecureBank—an end-to-end secure, cloud-native microservices banking platform conforming to OWASP ASVS v5.0 and Zero Trust architecture. Our stack includes FastAPI microservices, an API gateway, Kafka for event streaming, HashiCorp Vault for secrets management, and a complete DevSecOps CI/CD and SIEM logging pipeline. As seen in the architecture diagram, all traffic flows through our API Gateway, enforcing strict boundary isolation."*

### ⏱️ 1:30 - 3:30 | The Golden Path (Login & MFA)
* **On-Screen Visuals:** Open the browser to the banking GUI (`http://localhost:8080`).
* **Presenter Actions:**
  1. Click **Sign out** (top right) to return to the login page.
  2. Explain credential protection. Enter `demo@securebank.local` and `Change-Me-On-First-Login!`.
  3. Show the MFA page. Enter a 6-digit verification code.
  4. Land on the Dashboard. Go to the **Accounts** tab and open a new USD account.
  5. Go to the **Transfer** tab, choose "Ali Raza", select "₨ 2,500", and click **Send**. Show the transaction receipt with the cryptographic signature.
* **Talking Points:**
  > *"Every login is protected against brute-force attacks via Argon2id hashing and checks password databases using the HaveIBeenPwned API. Once valid, the system enforces multi-factor authentication (MFA TOTP) compliant with RFC 6238. In the dashboard, opening an account or executing a transfer sends a cryptographically signed transaction payload via Kafka using mTLS and ACLs. The ML model evaluates the fraud score in real time before accepting the ledger update."*

### ⏱️ 3:30 - 4:45 | Step-Up MFA & Policy-as-Code
* **On-Screen Visuals:** Browser at the **Transfer** tab.
* **Presenter Actions:**
  1. On the transfer form, select recipient Noor Ahmed.
  2. Input an amount of **₨ 25,000** (or click the ₨ 25,000 chip).
  3. Click **Send**.
  4. Highlight the red warning toast: *"Risky transfer blocked — step-up MFA required."*
* **Talking Points:**
  > *"Notice how the transfer fails. We have implemented context-aware authorization. Any transaction above ₨10,000 is classified as high-risk. This policy is written in Rego and evaluated server-side by Open Policy Agent (OPA). Even if an attacker compromises the frontend client code, they cannot bypass this OPA threshold because the policy decision is verified strictly at the API Gateway before hitting the transaction microservice."*

### ⏱️ 4:45 - 6:00 | Security Console & SIEM Overview
* **On-Screen Visuals:** Navigate to the **Security** tab in the top navigation bar.
* **Presenter Actions:** Scroll down the Security Console. Point to the four KPI cards (Login Failures, Rate Limits, Fraud Alerts, Falco Events), the scrolling Live Audit Feed, and the list of active offenses.
* **Talking Points:**
  > *"This is our Blue Team Security Console. Every action on the platform—whether a failed login, a blocked SSRF request, or a rate limit breach—generates structured audit logs forwarded to Grafana Loki and QRadar. Here we see real-time KPIs and the Active Offenses panel, which interfaces with our SOAR auto-containment playbooks."*

### ⏱️ 6:00 - 8:30 | Red Team vs. Blue Team Drills (Attacks 1-5)
* **On-Screen Visuals:** Security Console tab in the browser.
* **Presenter Actions:**
  1. Click **Credential Stuffing**. Show the audit feed filling with wrong password logs, the counter incrementing, and the QRadar lock-out offense.
  2. Click **JWT alg=none**. Point out the `401 Unauthorized` response.
  3. Click **SQL Injection**. Point out how input validators block the `' OR 1=1 --` email string.
  4. Click **SSRF — link-local**. Point out how the system blocks the request to AWS metadata (`169.254.169.254`).
  5. Click **Rate limit flood**. Show the 429 too-many-requests triggers.
* **Talking Points:**
  > *"Now we will execute five live Red Team attacks. When we click Credential Stuffing, OPA detects the brute force, triggers account lockout after 5 attempts, and SOAR blocks the attacker's IP. In our JWT alg=none attack, the gateway rejects the token because of our algorithm whitelist. The SQL Injection attempt is blocked at the gateway by strict Pydantic models. Our SSRF drill blocks link-local addresses, preventing cloud metadata exfiltration. Finally, our rate-limit flood triggers HTTP 429s, protecting backend services from denial of service."*

### ⏱️ 8:30 - 11:00 | Signature Drill: Memory Safety (C Code)
* **On-Screen Visuals:** PowerShell terminal and VS Code displaying `vuln.c` vs `hardened.c`.
* **Presenter Actions:**
  1. Run the vulnerable binary attack:
     ```powershell
     docker run --rm securebank/vuln:demo bash attack.sh
     ```
     Highlight the crash status (Exit code 139 / Segmentation Fault).
  2. Run the hardened binary attack:
     ```powershell
     docker run --rm --entrypoint=/hardened securebank/hardened:demo bof "$('A' * 300)"
     ```
     Highlight the clean abort: `*** stack smashing detected ***`.
  3. Show the compilation mitigation verification script:
     ```powershell
     docker run --rm --entrypoint=/verify_hardening.sh securebank/hardened:demo
     ```
  4. Return to the browser, click the **"Memory corruption (drill)"** button, and show the Falco event and QRadar offense generated.
* **Talking Points:**
  > *"To demonstrate mitigation against binary exploits (CWE-121, CWE-134), we wrote a simulated C banking handler. Running the vulnerable image causes a memory corruption crash, illustrating how buffer overflows take down legacy code. When we run our hardened container with the exact same payload, the OS refuses stack manipulation. We configured compiler flags including Stack Canaries, No-Execute (NX) stacks, Full RELRO, and Position Independent Executables (PIE). Falco runtime security flags the execution, triggers a memory corruption offense, and prompts the SOAR service to quarantine the compromised container."*

### ⏱️ 11:00 - 13:00 | ML Fraud Detection & AI Security Agent
* **On-Screen Visuals:** Go to the Transfer tab, then switch to a PowerShell window.
* **Presenter Actions:**
  1. Transfer ₨ 9,500 multiple times rapidly in the UI.
  2. Point out the account indicator changing to `frozen` due to the ML model flagging a "salami-slicing" transaction pattern.
  3. Run the AI agent explanation query:
     ```powershell
     curl.exe -s -X POST http://127.0.0.1:8007/explain -H "Content-Type: application/json" -d '{\"rule_id\":\"fraud-ml\",\"context\":{\"src_account_id\":\"acc-0001\"}}'
     ```
     Show the detailed JSON response explaining the attack.
* **Talking Points:**
  > *"Our transactions are monitored by a machine learning model. By sending multiple transactions just below the 10,000 rupee threshold, the model identifies transaction drift and triggers account freezing via SOAR. We've also built an AI Security Agent. Querying its endpoint explains the transaction fraud in plain English, maps the event to MITRE ATT&CK techniques, and recommends containment steps."*

### ⏱️ 13:00 - 14:00 | Grafana Dashboards & Metrics
* **On-Screen Visuals:** Grafana dashboard tab (`http://localhost:3000`).
* **Presenter Actions:** Hover over the Grafana panels showing CPU charts, authentication failure spikes, and Falco events.
* **Talking Points:**
  > *"Here is the Grafana dashboard showing our operational and security metrics. We can monitor the auth failure spikes from our credential stuffing drill and audit logs generated by our containers. The dashboard tracks our overall CIS compliance score, showing 92% compliance for our Docker daemon and 96% for Kubernetes configurations."*

### ⏱️ 14:00 - 15:00 | Conclusion & Rubric Scorecard
* **On-Screen Visuals:** Slide 18 (Rubric Scorecard / Completion Status).
* **Presenter Actions:** Point out the completion checklist and the bonus point sections.
* **Talking Points:**
  > *"In summary, we have implemented all requirements from the CYC386 rubric, mapping them to concrete evidence in our repository. We self-scored 100/100, plus an additional 15 bonus points for the AI Security Agent, SOAR service, advanced QRadar rule integrations, and adversarial ML probes. All threat models, compliance reports, and architecture decisions are documented in detail in our `/docs` folder. Thank you for your time, and we are happy to take any questions."*

---

## 🧹 Post-Recording Cleanup

Once you have finished recording, clean up your Docker resources to free up ports and system memory:

```powershell
# Stop all containers and delete volumes
cd docker
docker compose down -v
```

If you ran the Plan B server, terminate the Python process:
```powershell
# Find and stop the Python http.server
Get-Process python | Where-Object { $_.CommandLine -like '*http.server*8089*' } | Stop-Process
```
