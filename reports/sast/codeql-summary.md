# CodeQL — Latest Run

**Run date:** 2026-05-17
**Suite:** security-extended + security-and-quality
**Languages:** python, javascript

| Severity | Open | Closed |
|----------|------|--------|
| Critical | 0 | 4 |
| High     | 0 | 9 |
| Medium   | 1 | 11 |
| Low      | 3 | 18 |

## Open findings

| ID | Rule | File | Severity | Status |
|----|------|------|----------|--------|
| CQ-21 | `py/log-sensitive-information` | `src/auth-service/app/routes_auth.py:54` | Medium | Accepted (redaction filter catches at runtime; documented) |
| CQ-22 | `py/clear-text-storage-sensitive-data` | `docker/scripts/init-vault.sh:7` | Low | Accepted (dev-only script) |
| CQ-23 | `py/incomplete-url-substring-sanitization` | `src/shared/securebank_shared/url_safety.py:48` | Low | False positive — DNS pin + IP check fully resolves |
| CQ-24 | `js/missing-rate-limiter` | `src/frontend/index.html` | Low | N/A — static client |

Full SARIF: uploaded to GitHub Security tab.
