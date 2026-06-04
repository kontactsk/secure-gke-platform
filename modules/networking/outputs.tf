# ---------------------------------------------------
# Networking Module Outputs
# Purpose: Expose network details for other modules
# ---------------------------------------------------

output "vpc_id" {
  description = "ID of the created VPC"
  value       = google_compute_network.vpc.id
}

output "vpc_name" {
  description = "Name of the created VPC"
  value       = google_compute_network.vpc.name
}

output "subnet_id" {
  description = "ID of the private subnet"
  value       = google_compute_subnetwork.private_subnet.id
}

output "subnet_name" {
  description = "Name of the private subnet"
  value       = google_compute_subnetwork.private_subnet.name
}