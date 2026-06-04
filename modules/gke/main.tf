resource "google_service_account" "gke_sa" {
  project      = var.project_id
  account_id   = "${var.cluster_name}-sa"
  display_name = "Managed by Terraform - GKE Node Service Account"
}

resource "google_project_iam_member" "gke_sa_roles" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
  ])
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.gke_sa.email}"
}

resource "google_container_cluster" "primary" {
  project  = var.project_id
  name     = var.cluster_name
  location = var.region

  network    = var.network_id
  subnetwork = var.subnet_id

  # Remove default node pool immediately
  remove_default_node_pool = true
  initial_node_count       = 1

  # Enable Workload Identity
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Private cluster configuration
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  ip_allocation_policy {
    cluster_ipv4_cidr_block  = "10.1.0.0/16"
    services_ipv4_cidr_block = "10.2.0.0/16"
  }

  # Master authorization - restrict API access
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "0.0.0.0/0"
      display_name = "Allow all for dev - restrict in prod"
    }
  }
}
resource "google_container_node_pool" "primary_nodes" {
  project    = var.project_id
  name       = "${var.cluster_name}-node-pool"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = var.node_count

  node_config {
    machine_type    = var.machine_type
    service_account = google_service_account.gke_sa.email

    # Workload Identity on nodes
    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      env        = "dev"
      managed-by = "terraform"
      platform   = "secure-gke"
    }
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}
