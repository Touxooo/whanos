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
  zone = "europe-west9-a"

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
    ports = ["8080"]
  }

  allow {
    protocol = "udp"
    ports = ["8080"]
  }

  source_ranges = [
    "0.0.0.0/0"
  ]
}

resource "google_artifact_registry_repository" "whanos-befunge" {
  repository_id = "whanos-befunge"
  location = "europe-west9"
  format = "DOCKER"
}

resource "google_artifact_registry_repository" "whanos-c" {
  repository_id = "whanos-c"
  location = "europe-west9"
  format = "DOCKER"
}

resource "google_artifact_registry_repository" "whanos-java" {
  repository_id = "whanos-java"
  location = "europe-west9"
  format = "DOCKER"
}

resource "google_artifact_registry_repository" "whanos-javascript" {
  repository_id = "whanos-javascript"
  location = "europe-west9"
  format = "DOCKER"
}

resource "google_artifact_registry_repository" "whanos-python" {
  repository_id = "whanos-python"
  location = "europe-west9"
  format = "DOCKER"
}

# resource "google_container_cluster" "primary" {
#     name               = "whanos-terraform-cluster"
#     location           = "europe-west9-a"

#     remove_default_node_pool = true
#     initial_node_count = 1
# }

# resource "google_container_node_pool" "primary_preemptible_nodes" {
#     name       = "whanos-terraform-pool"
#     location   = "europe-west9-a"
#     cluster    = google_container_cluster.primary.name

#     node_count = 3

#     node_config {
#         preemptible  = true
#         machine_type = "e2-medium"

#         service_account = google_service_account.default.email
#         oauth_scopes    = [
#             "https://www.googleapis.com/auth/cloud-platform"
#         ]

#         disk_size_gb = "30"
#     }
# }

output "ip" {
    value = google_compute_instance.default.network_interface[0].access_config[0].nat_ip
}
