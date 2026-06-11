# OWASP ZAP Baseline Scan — Summary

**Date:** 2026-05-17
**Target:** https://api.securebank.local
**ZAP version:** 2.15.0
**Profile:** baseline (no active scan)

## Result: ✅ PASS (Quality Gate)

| Risk | Count | Notes |
|------|-------|-------|
| High | 0 | — |
| Medium | 2 | (1) `X-Frame-Options` echoed by upstream — overridden to DENY by gateway. (2) `Permissions-Policy` not set on `/openapi.json` — internal-only path. |
| Low | 5 | Cookie samesite, missing CT-RP on 404, etc. — accepted in academic scope. |
| Informational | 18 | — |

## Headers verified

- Strict-Transport-Security ✓
- Content-Security-Policy ✓
- X-Content-Type-Options ✓
- X-Frame-Options ✓
- Referrer-Policy ✓
- Permissions-Policy ✓ (on user-facing endpoints)

## Injection probes (active full scan, separate run, 2026-05-16)

| Vector | Result |
|--------|--------|
| SQL injection | NOT vulnerable (all responses identical for malicious vs. clean inputs) |
| Path traversal | NOT vulnerable |
| XSS reflected | NOT vulnerable |
| XSS persistent (memo) | NOT vulnerable (bleach + CSP) |
| SSRF in webhook URL | NOT vulnerable (post-F7 fix) |
| Command injection | NOT vulnerable |
| LDAP / XPath / NoSQL | N/A |

Full HTML report: `zap-baseline-2026-05-17.html`.
