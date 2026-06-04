# ---------------------------------------------------
# Dev Environment - Secure GKE Platform
# Purpose: Development infrastructure using reusable modules
# Owner: Platform Engineering Team
# ---------------------------------------------------

terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  backend "gcs" {
    bucket = "secure-gke-platform-dev-tfstate"
    prefix = "environments/dev"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "app_service_account" {
  source               = "../../modules/iam"
  project_id           = var.project_id
  service_account_name = "app-sa-dev"
  role                 = "roles/storage.objectViewer"
}


module "networking" {
  source      = "../../modules/networking"
  project_id  = var.project_id
  region      = var.region
  vpc_name    = "secure-gke-vpc"
  subnet_cidr = "10.0.0.0/24"
}


module "gke" {
  source       = "../../modules/gke"
  project_id   = var.project_id
  region       = var.region
  cluster_name = "secure-gke-dev"
  network_id   = module.networking.vpc_id
  subnet_id    = module.networking.subnet_id
  node_count   = 1
  machine_type = "e2-standard-2"
}