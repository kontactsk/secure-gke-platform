# ---------------------------------------------------
# Networking Module - Enterprise Pattern
# Purpose: Private VPC with secure subnet and firewall
# Owner: Platform Engineering Team
# ---------------------------------------------------

resource "google_compute_network" "vpc" {
  project                 = var.project_id
  name                    = var.vpc_name
  auto_create_subnetworks = false
  description             = "Managed by Terraform - Private VPC for secure workloads"
}

resource "google_compute_subnetwork" "private_subnet" {
  project                  = var.project_id
  name                     = "${var.vpc_name}-private-subnet"
  ip_cidr_range            = var.subnet_cidr
  region                   = var.region
  network                  = google_compute_network.vpc.id
  private_ip_google_access = true
}

resource "google_compute_router" "router" {
  project = var.project_id
  name    = "${var.vpc_name}-router"
  region  = var.region
  network = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "nat" {
  project                            = var.project_id
  name                               = "${var.vpc_name}-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

resource "google_compute_firewall" "deny_all_ingress" {
  project     = var.project_id
  name        = "${var.vpc_name}-deny-all-ingress"
  network     = google_compute_network.vpc.id
  direction   = "INGRESS"
  priority    = 1000
  description = "Deny all ingress traffic by default - enterprise security baseline"

  deny {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_internal" {
  project     = var.project_id
  name        = "${var.vpc_name}-allow-internal"
  network     = google_compute_network.vpc.id
  direction   = "INGRESS"
  priority    = 900
  description = "Allow internal subnet traffic only"

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = [var.subnet_cidr]
}