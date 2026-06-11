# Trivy Image Scan — Summary

**Date:** 2026-05-17

| Image | OS pkgs HIGH/CRITICAL | App deps HIGH/CRITICAL | Secrets | Result |
|-------|----------------------|------------------------|---------|--------|
| `auth-service:1.0.0` | 0 / 0 | 0 / 0 | 0 | ✅ |
| `account-service:1.0.0` | 0 / 0 | 0 / 0 | 0 | ✅ |
| `transaction-service:1.0.0` | 0 / 0 | 0 / 0 | 0 | ✅ |
| `fraud-detection-service:1.0.0` | 0 / 0 | 0 / 0 | 0 | ✅ |
| `notification-service:1.0.0` | 0 / 0 | 0 / 0 | 0 | ✅ |
| `api-gateway:1.0.0` | 0 / 0 | 0 / 0 | 0 | ✅ |
| `frontend:1.0.0` (nginx-alpine) | 0 / 0 | n/a | 0 | ✅ |

Distroless base + multi-stage build keep the image surface tiny — there is no shell, no package manager, no extra binaries to find vulns in.

SBOM (CycloneDX): generated in CI via `docker buildx ... --sbom=true` and uploaded as a build attestation, then verified by Kyverno at admission.
