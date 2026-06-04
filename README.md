# Secure GKE Platform

Enterprise-grade secure Kubernetes platform on Google Cloud Platform (GCP),
built using Terraform with security and compliance as core design principles.

## Architecture Overview

This platform follows banking-grade security patterns used in regulated
enterprises, implementing defense-in-depth across all layers.
┌─────────────────────────────────────────────┐
│           GCP Project (Dedicated)           │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │         Private VPC                 │   │
│  │                                     │   │
│  │  ┌──────────────────────────────┐  │   │
│  │  │     Private GKE Cluster      │  │   │
│  │  │  - No public node IPs        │  │   │
│  │  │  - Workload Identity enabled │  │   │
│  │  │  - Auto-repair + upgrade     │  │   │
│  │  └──────────────────────────────┘  │   │
│  │                                     │   │
│  │  Cloud NAT (outbound only)          │   │
│  │  Firewall: deny-all ingress         │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  Remote State: GCS bucket + versioning      │
└─────────────────────────────────────────────┘

## Security Design Principles

- **Least Privilege IAM** — dedicated service accounts per workload
- **Private Nodes** — no public IPs on any compute resource
- **Workload Identity** — no static service account keys
- **Default Deny** — all ingress blocked unless explicitly allowed
- **Immutable Infrastructure** — all changes through Terraform only
- **Remote State** — GCS backend with versioning for recovery

## Project Structure
secure-gke-platform/
├── modules/
│   ├── iam/           # Reusable least-privilege IAM module
│   ├── networking/    # Private VPC, NAT, firewall rules
│   └── gke/           # Private GKE cluster + node pool
├── environments/
│   └── dev/           # Dev environment configuration
└── docs/
└── security-model.md

## Modules

### IAM Module
Creates least-privilege service accounts with explicit role bindings.
No wildcard permissions. One service account per workload.

### Networking Module
- Custom mode VPC (no auto-subnets)
- Private subnet with Cloud NAT
- Deny-all ingress firewall (priority 1000)
- Allow internal traffic only (priority 900)
- Private Google Access enabled

### GKE Module
- Private cluster (nodes have no public IPs)
- Workload Identity for pod-level GCP authentication
- Dedicated node service account with minimal roles
- Auto-repair and auto-upgrade enabled
- Custom node pool (default pool removed)

## Tech Stack

| Technology | Purpose |
|---|---|
| Terraform | Infrastructure as Code |
| Google Kubernetes Engine | Container orchestration |
| Google Cloud VPC | Private networking |
| Cloud NAT | Outbound-only connectivity |
| Workload Identity | Keyless authentication |
| GCS Backend | Remote state management |

## How to Deploy

```bash
# Authenticate
gcloud auth application-default login

# Initialize
cd environments/dev
terraform init

# Plan
terraform plan

# Apply
terraform apply
```

## Destroy (cost saving)

```bash
terraform destroy
```


## Author

Saikiran — Cloud Security & Platform Engineer
9+ years experience | GCP · Terraform · Kubernetes · IAM