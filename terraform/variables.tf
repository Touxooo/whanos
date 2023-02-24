variable "gcp_project" {
  type = string
  default = "whanos-terraform-test"
  description = "The GCP project to deploy to"
}

variable "gcp_zone" {
  type = string
  default = "europe-west9-a"
  description = "The GCP zone to deploy to"
}

variable "gcp_region" {
  type = string
  default = "europe-west9"
  description = "The GCP region to deploy to"
}