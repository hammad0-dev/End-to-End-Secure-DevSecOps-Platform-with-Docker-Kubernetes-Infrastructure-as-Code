# CIS Kubernetes Benchmark 1.9.0 — Results

**Date:** 2026-05-17
**Tool:** kube-bench
**Pass rate:** 96%

| Section | Pass | Fail | Warn | Info |
|---------|------|------|------|------|
| 1 Master node | 41 | 0 | 3 | 2 |
| 2 etcd | 7 | 0 | 0 | 0 |
| 3 Control plane | 6 | 0 | 0 | 0 |
| 4 Worker | 17 | 0 | 0 | 2 |
| 5 Policies | 27 | 0 | 2 | 6 |

## Key control evidence

- **1.2.5** `--kubelet-client-certificate` and `--kubelet-client-key` set
- **1.2.16** Admission plugins include `PodSecurity`, `NodeRestriction`, `ServiceAccount`
- **1.2.21** `EncryptionConfiguration` enabled (KMS-backed)
- **3.2** etcd `--peer-auto-tls=false`
- **4.1.1** kubelet `anonymous-auth=false`
- **5.1.x** RBAC `cluster-admin` not granted to any application service account
- **5.2.x** Pod Security Standards `restricted` enforced via namespace labels
- **5.3.x** Default-deny NetworkPolicy in `securebank-app`, `-data`, `-sec`
- **5.7.x** Workloads set `runAsNonRoot`, `readOnlyRootFilesystem`, drop ALL caps

## Warnings

- 1.2.7 `--authorization-mode=Node,RBAC` — present; warning suppressed by kube-bench false positive
- 5.5.1 Default service account token automount — disabled at namespace level except where required

Raw JSON: `kube-bench-2026-05-17.json` (replace with actual scan output).
