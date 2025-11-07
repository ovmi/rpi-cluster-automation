# Architecture Overview

This document describes the Raspberry Pi Cluster Automation Framework.

## Cluster Topology

```mermaid
graph TD
  A[node0 - Pi 5\nController + NVMe]
  B[node1 - Pi 5\nAI Node]
  C[node2 - Pi 4\nFuture Storage]
  D[node3 - Pi 4\nGluster Brick + LTE]

  Router --> Switch
  Switch --> A
  Switch --> B
  Switch --> C
  Switch --> D
  D -->|Backup WAN| LTE
```

> 📎 Fallback image if Mermaid is not rendered:

![Cluster Topology](media/ARCHITECTURE.png)

## Data Flows
- Control plane on node0
- Storage via GlusterFS volume
- K3s agents on all nodes
