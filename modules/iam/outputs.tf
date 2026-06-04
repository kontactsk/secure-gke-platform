# ---------------------------------------------------
# IAM Module Outputs
# Purpose: Expose service account details for other modules
# ---------------------------------------------------


output "service_account_email" {
  description = "Email of the created service account"
  value       = google_service_account.this.email
}

output "service_account_name" {
  description = "Full name of the created service account"
  value       = google_service_account.this.name
}