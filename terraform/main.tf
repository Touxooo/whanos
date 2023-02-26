terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

resource "google_service_account" "default" {
  account_id   = "whanos-terraform"
  display_name = "Whanos Terraform"
}

provider "google" {
  credentials = file("../key.json")

  project = var.gcp_project
  region  = var.gcp_region
  zone    = var.gcp_zone
}

resource "google_compute_instance" "default" {
  name = "whanos-terraform"
  machine_type = "e2-medium"
  zone = var.gcp_zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      type = "pd-standard"
      size = "30"
    }
  }

  network_interface {
      network = "default"
      access_config {
      }
  }

  metadata_startup_script = "${file("./startup.sh")}"
}

resource "google_compute_firewall" "default" {
  name = "whanos-terraform-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports = ["8080","80"]
  }

  allow {
    protocol = "udp"
    ports = ["8080","80"]
  }

  source_ranges = [
    "0.0.0.0/0"
  ]
}

resource "google_artifact_registry_repository" "whanos-befunge" {
  repository_id = "whanos-befunge"
  location = var.gcp_region
  format = "DOCKER"
}

resource "google_artifact_registry_repository" "whanos-c" {
  repository_id = "whanos-c"
  location = var.gcp_region
  format = "DOCKER"
}

resource "google_artifact_registry_repository" "whanos-java" {
  repository_id = "whanos-java"
  location = var.gcp_region
  format = "DOCKER"
}

resource "google_artifact_registry_repository" "whanos-javascript" {
  repository_id = "whanos-javascript"
  location = var.gcp_region
  format = "DOCKER"
}

resource "google_artifact_registry_repository" "whanos-python" {
  repository_id = "whanos-python"
  location = var.gcp_region
  format = "DOCKER"
}

resource "google_artifact_registry_repository" "whanos-cpp" {
  repository_id = "whanos-cpp"
  location = var.gcp_region
  format = "DOCKER"
}

resource "google_artifact_registry_repository" "whanos-go" {
  repository_id = "whanos-go"
  location = var.gcp_region
  format = "DOCKER"
}

resource "google_artifact_registry_repository" "whanos-rust" {
  repository_id = "whanos-rust"
  location = var.gcp_region
  format = "DOCKER"
}

resource "google_container_cluster" "primary" {
    name               = "whanos-terraform-cluster"
    location           = var.gcp_zone

    remove_default_node_pool = true
    initial_node_count = 1
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
    name       = "whanos-terraform-pool"
    location   = var.gcp_zone
    cluster    = google_container_cluster.primary.name

    node_count = 3

    node_config {
        preemptible  = true
        machine_type = "e2-medium"

        oauth_scopes    = [
            "https://www.googleapis.com/auth/cloud-platform",
            "https://www.googleapis.com/auth/logging.write",
            "https://www.googleapis.com/auth/monitoring",
            "https://www.googleapis.com/auth/devstorage.read_only",
            "https://www.googleapis.com/auth/service.management.readonly",
            "https://www.googleapis.com/auth/servicecontrol",
            "https://www.googleapis.com/auth/trace.append"
        ]

        disk_size_gb = "30"
    }
}

output "ip" {
    value = google_compute_instance.default.network_interface[0].access_config[0].nat_ip
}
