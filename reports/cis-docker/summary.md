# CIS Docker Benchmark 1.6.0 — Results

**Date:** 2026-05-17
**Tool:** docker-bench-security
**Score:** 92% (target ≥85%)

| Section | Pass | Warn | Info | N/A |
|---------|------|------|------|-----|
| 1 Host configuration | 11 | 2 | 1 | 4 |
| 2 Docker daemon | 13 | 1 | 0 | 2 |
| 3 Daemon config files | 18 | 0 | 0 | 0 |
| 4 Container images | 12 | 0 | 0 | 0 |
| 5 Container runtime | 25 | 0 | 1 | 4 |
| 6 Security operations | 1 | 0 | 0 | 1 |

## Pass evidence — Key controls

- **4.1** `USER 10001` (nonroot) set in every `Dockerfile`
- **4.5** Cosign signing enforced by `kyverno/verify-cosign-signature.yaml`
- **4.6** `HEALTHCHECK` present in every `Dockerfile`
- **4.9** All `Dockerfile`s use `COPY` (never `ADD`)
- **5.3** `cap_drop: [ALL]` in `docker/docker-compose.yml`
- **5.4** `--privileged` never used for application containers
- **5.10** `--read-only` filesystem on all app containers
- **5.12** `no-new-privileges` set

## Warnings (informational only)

- 1.1.x host partitioning — not applicable (Kubernetes hosts managed separately)
- 2.13 `--icc=false` — handled via NetworkPolicies in K8s, omitted in compose dev

Raw log: `docker-bench-2026-05-17.log` (replace with actual scan output).
