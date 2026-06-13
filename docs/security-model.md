# Security Model

## Overview

This platform implements defense-in-depth security across all layers.
Every decision has a security reason. This document explains why, not just what.

## 1. Identity & Access Management

### Design Decision: One Service Account Per Workload

Each workload gets its own dedicated service account with only
the permissions it needs. No shared service accounts.

**Why:**
Shared service accounts mean if one workload is compromised,
the attacker gets access to everything that service account
can reach. Isolation limits blast radius.

**Implementation:**
- app-sa-dev: roles/storage.objectViewer only
- gke-node-sa: logging + monitoring roles only
- No roles/editor or roles/owner anywhere

### Design Decision: Workload Identity Over Static Keys

GKE pods authenticate to GCP using Workload Identity,
not downloaded service account key files.

**Why:**
Static key files can be stolen, accidentally committed to Git,
or left in container images. Workload Identity eliminates
the key entirely - there is nothing to steal.

## 2. Network Security

### Design Decision: Private Nodes Only

All GKE nodes have private IPs only. No public IP addresses
on any compute resource.

**Why:**
Public IPs create attack surface. Every public IP is a potential
entry point for attackers. Private nodes are unreachable
from the internet by design.

### Design Decision: Deny-All Ingress Firewall

Default firewall rule denies all incoming traffic.
Only explicitly allowed traffic passes through.

**Why:**
Allow-by-default means you must remember to block
every threat. Deny-by-default means you only open
what you intentionally need. Regulated environments
require this approach.

**Implementation:**
- Priority 1000: deny all ingress from 0.0.0.0/0
- Priority 900: allow internal subnet traffic only

### Design Decision: Cloud NAT for Outbound Only

Workloads can reach internet for updates and dependencies
but cannot be reached from internet.

**Why:**
One-way connectivity. Attackers cannot initiate
connections to your workloads even if they know the IP range.

## 3. Infrastructure as Code Security

### Design Decision: Remote State in GCS

Terraform state stored in GCS with versioning enabled.
Never stored locally or committed to Git.

**Why:**
State files contain sensitive resource details.
Versioning allows recovery if state is accidentally corrupted.

### Design Decision: No Hardcoded Values

All sensitive values in terraform.tfvars which is gitignored.
Example file provided for reference.

**Why:**
Hardcoded values in code create security and portability problems.
Separation of code and configuration is fundamental.

## 4. Compliance Relevance

This security model directly addresses requirements in:
- Financial services (PCI-DSS, SOX)
- Healthcare (HIPAA)
- Banking regulations

## Summary

| Security Control | Implementation | Why It Matters |
|---|---|---|
| Least Privilege IAM | Per-workload service accounts | Limits blast radius |
| No Static Keys | Workload Identity | Eliminates credential theft |
| Private Nodes | No public IPs | Removes attack surface |
| Default Deny | Firewall priority 1000 | Forces explicit allowance |
| Remote State | GCS + versioning | Protects sensitive data |
| No Hardcoded Values | tfvars gitignored | Prevents secret exposure |