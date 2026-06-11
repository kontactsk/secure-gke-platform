"""
IAM Security Audit Script
Purpose: Detect over-privileged service accounts in GCP project
Owner: Platform Engineering Team

Usage: python iam_audit.py
"""

from googleapiclient import discovery
import google.auth

# Roles considered dangerous - too much access
RISKY_ROLES = [
    "roles/owner",
    "roles/editor",
    "roles/iam.securityAdmin",
    "roles/iam.serviceAccountAdmin",
]

PROJECT_ID = "secure-gke-platform-dev"


def get_iam_policy(project_id):
    """Fetch the IAM policy for the project."""
    credentials, _ = google.auth.default()
    service = discovery.build(
        "cloudresourcemanager", "v1", credentials=credentials
    )
    policy = service.projects().getIamPolicy(
        resource=project_id, body={}
    ).execute()
    return policy


def audit_policy(policy):
    """Check policy bindings for risky roles."""
    violations = []
    safe_bindings = []

    for binding in policy.get("bindings", []):
        role = binding["role"]
        members = binding["members"]

        if role in RISKY_ROLES:
            for member in members:
                violations.append({
                    "member": member,
                    "role": role,
                    "severity": "HIGH"
                })
        else:
            for member in members:
                safe_bindings.append({
                    "member": member,
                    "role": role
                })

    return violations, safe_bindings


def print_report(violations, safe_bindings):
    """Print audit results in readable format."""
    print("=" * 60)
    print("IAM SECURITY AUDIT REPORT")
    print(f"Project: {PROJECT_ID}")
    print("=" * 60)

    if violations:
        print(f"\nVIOLATIONS FOUND: {len(violations)}\n")
        for v in violations:
            print(f"  [{v['severity']}] {v['member']}")
            print(f"         has risky role: {v['role']}\n")
    else:
        print("\nNo high-risk IAM bindings found.")

    print(f"\nTotal safe bindings: {len(safe_bindings)}")
    print("=" * 60)


def main():
    print("Starting IAM audit...")
    policy = get_iam_policy(PROJECT_ID)
    violations, safe_bindings = audit_policy(policy)
    print_report(violations, safe_bindings)

    if violations:
        print("ACTION REQUIRED: Review and remove risky roles")
        return 1
    return 0


if __name__ == "__main__":
    exit(main())