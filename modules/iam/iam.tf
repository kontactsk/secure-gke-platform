# ---------------------------------------------------
# IAM Module - Enterprise Pattern
# Purpose: Creates a least-privilege service account
# Owner: Platform Engineering Team
# ---------------------------------------------------


resource "google_service_account" "this" {
  project      = var.project_id
  account_id   = var.service_account_name
  display_name = "Managed by Terraform - ${var.service_account_name}"
}

resource "google_project_iam_member" "this" {
  project = var.project_id
  role    = var.role
  member  = "serviceAccount:${google_service_account.this.email}"
}