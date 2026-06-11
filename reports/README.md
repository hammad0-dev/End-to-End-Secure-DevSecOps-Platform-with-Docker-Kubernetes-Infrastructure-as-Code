# `/reports` — Evidence Pack

This directory contains the latest scan & test outputs referenced by the
compliance docs in `/docs`.

| Sub-folder | Tool | Headline result |
|-----------|------|-----------------|
| `sast/` | SonarQube, CodeQL | 0 Critical/Blocker; coverage 78% |
| `dast/` | OWASP ZAP | 0 High, 2 accepted Medium |
| `pentest/` | Manual + Python probes | All 14 findings closed |
| `cis-docker/` | docker-bench | 92% |
| `cis-k8s/` | kube-bench | 96% |
| `trivy/` | Trivy image scan | 0 High/Critical across all images |

Raw outputs (`.log`, `.json`, `.sarif`, `.html`) belong here too in a real
engagement; for the academic submission the summary markdowns are
authoritative.
